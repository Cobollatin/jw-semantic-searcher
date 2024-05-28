using Indexer.Services;
using Indexer.Models;
using Azure.Search.Documents.Models;
using System;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

namespace Indexer
{
    class Program
    {
        static async Task Main(string[] args)
        {
            string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME");
            string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME");
            string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY");

            var searchService = new AzureSearchService(serviceName, indexName, apiKey);

            var index = new SearchIndex(indexName)
            {
                Fields =
                {
                    new SimpleField("id", SearchFieldDataType.String) { IsKey = true, IsFilterable = true },
                    new SearchableField("content") { IsFilterable = true, IsSortable = true }
                }
            };

            await searchService.CreateOrUpdateIndexAsync(index);

            string dataFilePath = Path.Combine(Directory.GetCurrentDirectory(), "data.json");
            string json = await File.ReadAllTextAsync(dataFilePath);
            var documents = JsonSerializer.Deserialize<Document[]>(json);

            await searchService.UploadDocumentsAsync(documents);

            Console.WriteLine("Index updated successfully.");
        }
    }
}
