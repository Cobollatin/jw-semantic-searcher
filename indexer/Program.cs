using Azure.Search.Documents.Indexes.Models;
using Indexer.Models;
using Indexer.Services;

string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME");
string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME");
string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY");

var searchService = new AzureSearchService(serviceName, indexName, apiKey);

var index = new SearchIndex(indexName)
{
    Fields =
    {
        new SearchableField("title") { IsFilterable = true, IsSortable = true},
        new SearchableField("preview") { IsFilterable = true, IsSortable = true },
        new SearchableField("url") { IsFilterable = true, IsSortable = true }
    }
};

await searchService.CreateOrUpdateIndexAsync(index);

var documents = new List<Document>
{
    new Document { Title = "", Preview = "This is a preview of document 1", Url = "http://example.com/1" },
    new Document { Title = "2", Preview = "This is a preview of document 2", Url = "http://example.com/2" },
    new Document { Title = "3", Preview = "This is a preview of document 3", Url = "http://example.com/3" }
};

await searchService.UploadDocumentsAsync(documents);

Console.WriteLine("Index updated successfully with mock data.");
