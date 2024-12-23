﻿using System.Collections.Concurrent;
using System.Text.Json;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;
using Indexer.Models;
using Indexer.Services;
using Microsoft.Extensions.Logging;
using OpenAI_API;
using OpenAI_API.Models;

using ILoggerFactory factory = LoggerFactory.Create(builder => builder.AddConsole().SetMinimumLevel(LogLevel.Error));
var logger = factory.CreateLogger("Indexer");

string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SERVICE_NAME");
string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_INDEX_NAME");
string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY") ?? throw new ArgumentNullException("AZURE_SEARCH_API_KEY");
string semanticConfigName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SEMANTIC_CONFIG_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SEMANTIC_CONFIG_NAME");

string enableSemticSearh = Environment.GetEnvironmentVariable("AZURE_SEARCH_SEMANTIC_CONFIG_NAME") ?? throw new ArgumentNullException("ENABLE_SEMANTIC_SEARCH");

var searchService = new AzureSearchService(serviceName, indexName, apiKey);

var fields = new FieldBuilder().Build(typeof(Document));
var semanticSearch = new SemanticSearch()
{
    Configurations =
    {
        new SemanticConfiguration(semanticConfigName, new()
        {
            TitleField = new SemanticField("Title"),
            ContentFields =
            {
                new SemanticField("Content")
            },
            KeywordsFields =
            {
                new SemanticField("Url")
            },
        })
    }
};
var vectorSearch = new VectorSearch
{
    Profiles = {
        new VectorSearchProfile(DocumentConstants.DocumentSearchProfile, semanticConfigName)
    },
    Algorithms = {
        new HnswAlgorithmConfiguration(semanticConfigName){
            Parameters = new HnswParameters() {
                    EfConstruction = 400,
                    EfSearch = 500,
                    M = 4,
                    Metric = VectorSearchAlgorithmMetric.Cosine
                }
        }
    }
};

var index = new SearchIndex(indexName)
{
    Fields = fields,
    SemanticSearch = semanticSearch,
    VectorSearch = vectorSearch
};

if (enableSemticSearh == "false")
{
    semanticSearch = null;
}

string openAiKey = Environment.GetEnvironmentVariable("OPENAI_KEY") ?? throw new ArgumentNullException("OPENAI_KEY");
string deploymentName = Environment.GetEnvironmentVariable("OPENAI_DEPLOYMENT_NAME") ?? throw new ArgumentNullException("OPENAI_DEPLOYMENT_NAME");
string openAiOrgId = Environment.GetEnvironmentVariable("OPENAI_ORG_ID") ?? throw new ArgumentNullException("OPENAI_ORG_ID");
var openAIClient = new OpenAIAPI(new APIAuthentication(openAiKey, openAiOrgId));

CancellationTokenSource cancellationTokenSource = new();
CancellationToken cancellationToken = cancellationTokenSource.Token;

await searchService.DeleteIndexAsync(indexName, cancellationToken);
await searchService.CreateOrUpdateIndexAsync(index, cancellationToken);

const string path = "./data";

var filesInDirectory = Directory.GetFiles(path, "*.json", SearchOption.AllDirectories);

int fileParallelism = 4;

await Parallel.ForEachAsync(filesInDirectory, new ParallelOptions
{
    MaxDegreeOfParallelism = fileParallelism,
    CancellationToken = cancellationToken
},
async (file, ct) =>
{
    var fileMetadata = new FileInfo(file);

    if (fileMetadata.Length == 0)
    {
        logger.LogWarning("File {file} is empty, skipping.", file);
        return;
    }

    if (fileMetadata.Length > 1200000)
    {
        logger.LogWarning("File {file} is too large, skipping (max size is 1MB).", file);
        return;
    }

    string json;
    try
    {
        json = await File.ReadAllTextAsync(file, ct);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Failed to read file {file}. Skipping.", file);
        return;
    }

    List<PartialDocument>? partialDocuments;
    try
    {
        partialDocuments = JsonSerializer.Deserialize<List<PartialDocument>>(json);
    }
    catch (JsonException ex)
    {
        logger.LogError(ex, "Failed to deserialize JSON in file {file}. Skipping.", file);
        return;
    }

    if (partialDocuments == null || partialDocuments.Count == 0)
    {
        logger.LogWarning("File {file} contains no documents, skipping.", file);
        return;
    }

    int documentParallelism = 4;

    var documents = new ConcurrentBag<Document>();

    await Parallel.ForEachAsync(partialDocuments, new ParallelOptions
    {
        MaxDegreeOfParallelism = documentParallelism,
        CancellationToken = ct
    },
    async (document, documentCt) =>
    {
        try
        {
            var model = new Model(deploymentName);
            var descriptionVector = await openAIClient.Embeddings.GetEmbeddingsAsync(document.Content, model, DocumentConstants.DescriptionVectorDimension);

            var documentToAdd = new Document
            {
                Id = Guid.NewGuid().ToString("n"),
                Title = document.Title,
                Content = document.Content,
                Url = document.Url,
                DescriptionVector = descriptionVector
            };

            documents.Add(documentToAdd);
            logger.LogInformation("Document added: {documentId}", documentToAdd.Id);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to process document in file {file}.", file);
        }
    });

    if (!documents.IsEmpty)
    {
        try
        {
            await searchService.UploadDocumentsAsync(documents.ToList(), ct);
            logger.LogInformation("Documents uploaded: {count} from {file}", documents.Count(), file);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to upload documents from file {file}.", file);
        }
    }
});

logger.LogInformation("Index updated successfully with mock data.");
return 0;