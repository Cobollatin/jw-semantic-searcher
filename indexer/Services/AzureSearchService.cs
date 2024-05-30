using Azure;
using Azure.Search.Documents;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;
using Azure.Search.Documents.Models;
using Indexer.Models;

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

        public async Task CreateOrUpdateIndexAsync(SearchIndex index, CancellationToken cancellationToken = default)
        {
            await _indexClient.CreateOrUpdateIndexAsync(index, cancellationToken: cancellationToken);
        }

        public async Task UploadDocumentsAsync(IEnumerable<Document> documents, CancellationToken cancellationToken = default)
        {
            var batch = IndexDocumentsBatch.MergeOrUpload(documents);
            IndexDocumentsOptions options = new() { ThrowOnAnyError = true };
            await _searchClient.IndexDocumentsAsync(batch, options, cancellationToken: cancellationToken);
        }

        public async Task DeleteIndexAsync(string indexName, CancellationToken cancellationToken = default)
        {
            await _indexClient.DeleteIndexAsync(indexName, cancellationToken: cancellationToken);
        }
    }
}
