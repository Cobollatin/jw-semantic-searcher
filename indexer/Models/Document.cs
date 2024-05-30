using System.Text.Json.Serialization;
using Azure.Search.Documents.Indexes;

namespace Indexer.Models
{
    public class Document
    {
        [JsonPropertyName("Id")]
        [SimpleField(IsFilterable = true, IsSortable = true)]
        public required string Id { get; init; }
        [JsonPropertyName("Title")]
        [SearchableField(IsFilterable = true, IsSortable = true)]
        public required string Title { get; init; }
        [JsonPropertyName("Content")]
        [SearchableField(IsFilterable = true, IsSortable = false)]
        public required string Content { get; init; }
        [JsonPropertyName("Url")]
        [SearchableField(IsKey = true, IsFilterable = true, IsSortable = false)]
        public required string Url { get; init; }
    }
}
