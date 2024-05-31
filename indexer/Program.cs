using System.Text.Json;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;
using Indexer.Models;
using Indexer.Services;
using Microsoft.Extensions.Logging;
using OpenAI_API;
using OpenAI_API.Models;

using ILoggerFactory factory = LoggerFactory.Create(builder => builder.AddConsole());
var logger = factory.CreateLogger("Indexer");

string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SERVICE_NAME");
string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_INDEX_NAME");
string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY") ?? throw new ArgumentNullException("AZURE_SEARCH_API_KEY");
string semanticConfigName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SEMANTIC_CONFIG_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SEMANTIC_CONFIG_NAME");

var searchService = new AzureSearchService(serviceName, indexName, apiKey);

var fields = new FieldBuilder().Build(typeof(Document));
// var semanticSearch = new SemanticSearch()
// {
//     Configurations =
//     {
//         new SemanticConfiguration(semanticConfigName, new()
//         {
//             TitleField = new SemanticField("Title"),
//             ContentFields =
//             {
//                 new SemanticField("Content")
//             },
//             KeywordsFields =
//             {
//                 new SemanticField("Url")
//             },
//         })
//     }
// };
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
    // SemanticSearch = semanticSearch,
    VectorSearch = vectorSearch
};

string openAiKey = Environment.GetEnvironmentVariable("OPENAI_KEY") ?? throw new ArgumentNullException("OPENAI_KEY");
string deploymentName = Environment.GetEnvironmentVariable("OPENAI_DEPLOYMENT_NAME") ?? throw new ArgumentNullException("OPENAI_DEPLOYMENT_NAME");
string openAiOrgId = Environment.GetEnvironmentVariable("OPENAI_ORG_ID") ?? throw new ArgumentNullException("OPENAI_ORG_ID");
var openAIClient = new OpenAIAPI(new APIAuthentication(openAiKey, openAiOrgId));

CancellationTokenSource cancellationTokenSource = new();
CancellationToken cancellationToken = cancellationTokenSource.Token;

await searchService.DeleteIndexAsync(indexName, cancellationToken);
await searchService.CreateOrUpdateIndexAsync(index, cancellationToken);

var filesInDirectory = Directory.GetFiles("data", "*.json", SearchOption.AllDirectories);

foreach (var file in filesInDirectory)
{
    var fileMetadata = new FileInfo(file);

    if (fileMetadata.Length == 0)
    {
        logger.LogWarning("File {file} is empty, skipping", file);
        continue;
    }

    if (fileMetadata.Length > 1000000)
    {
        logger.LogWarning("File {file} is too large, skipping (max size is 1MB)", file);
        continue;
    }

    var json = File.ReadAllText(file);
    var partialDocuments = JsonSerializer.Deserialize<List<PartialDocument>>(json);
    if (partialDocuments == null)
    {
        logger.LogWarning("File {file} is empty, skipping", file);
        continue;
    }

    var documents = new List<Document>();

    foreach (var document in partialDocuments)
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
        logger.LogInformation("Document added: {document}", documentToAdd);
    }

    await searchService.UploadDocumentsAsync(documents, cancellationToken);
    logger.LogInformation("Documents uploaded: {count} from {file}", documents.Count, file);
}

Console.WriteLine("Index updated successfully with mock data.");
