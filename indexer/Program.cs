using Azure.Search.Documents.Indexes.Models;
using Indexer.Models;
using Indexer.Services;

string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SERVICE_NAME");
string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_INDEX_NAME");
string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY") ?? throw new ArgumentNullException("AZURE_SEARCH_API_KEY");

var searchService = new AzureSearchService(serviceName, indexName, apiKey);

var index = new SearchIndex(indexName)
{
    Fields =
    {
        new SearchableField("Title") { IsFilterable = true, IsSortable = true},
        new SearchableField("Content") { IsFilterable = true, IsSortable = true },
    }
};

await searchService.CreateOrUpdateIndexAsync(index);

var documents = new List<Document>
{
    new Document { Id =  Guid.NewGuid(), Title = "1", Content = "This is a preview of document 1", Url = "http://example.com/1" },
    new Document { Id =  Guid.NewGuid(), Title = "2", Content = "This is a preview of document 2", Url = "http://example.com/2" },
    new Document { Id =  Guid.NewGuid(), Title = "3", Content = "This is a preview of document 3", Url = "http://example.com/3" }
};

await searchService.UploadDocumentsAsync(documents);

Console.WriteLine("Index updated successfully with mock data.");
