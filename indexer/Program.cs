using Azure.Search.Documents;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;
using Azure.Search.Documents.Models;
using Indexer.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME");
string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME");
string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY");

var searchService = new AzureSearchService(serviceName, indexName, apiKey);

var index = new SearchIndex(indexName)
{
    Fields =
    {
        new SimpleField("id", SearchFieldDataType.String) { IsKey = true, IsFilterable = true },
        new SearchableField("preview") { IsFilterable = true, IsSortable = true },
        new SearchableField("url") { IsFilterable = true, IsSortable = true }
    }
};

await searchService.CreateOrUpdateIndexAsync(index);

var documents = new List<Document>
{
    new Document { Id = "1", Preview = "This is a preview of document 1", Url = "http://example.com/1" },
    new Document { Id = "2", Preview = "This is a preview of document 2", Url = "http://example.com/2" },
    new Document { Id = "3", Preview = "This is a preview of document 3", Url = "http://example.com/3" }
};

await searchService.UploadDocumentsAsync(documents);

Console.WriteLine("Index updated successfully with mock data.");
