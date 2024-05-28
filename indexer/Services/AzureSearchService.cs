using Azure;
using Azure.Search.Documents;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;
using System;
using System.Threading.Tasks;

namespace Indexer.Services
{
    public class AzureSearchService
    {
        private readonly SearchClient _searchClient;
        private readonly SearchIndexClient _indexClient;

        public AzureSearchService(string serviceName, string indexName, string apiKey)
        {
            string endpoint = $"https://{serviceName}.search.windows.net";
            _searchClient = new SearchClient(new Uri(endpoint), indexName, new AzureKeyCredential(apiKey));
            _indexClient = new SearchIndexClient(new Uri(endpoint), new AzureKeyCredential(apiKey));
        }

        public async Task<SearchResults<SearchDocument>> SearchDocumentsAsync(string query)
        {
            SearchOptions options = new SearchOptions { IncludeTotalCount = true };
            SearchResults<SearchDocument> results = await _searchClient.SearchAsync<SearchDocument>(query, options);
            return results;
        }

        public async Task CreateOrUpdateIndexAsync(SearchIndex index)
        {
            await _indexClient.CreateOrUpdateIndexAsync(index);
        }
    }
}
