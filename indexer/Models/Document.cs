using System.Text.Json.Serialization;
using Azure.Search.Documents.Indexes;

namespace Indexer.Models
{
    public class Document
    {
        [JsonPropertyName("Id")]
        [SimpleField(IsKey = true, IsFilterable = true, IsSortable = true)]
        public required string Id { get; private set; }
        [JsonPropertyName("Title")]
        [SearchableField(IsFilterable = true, IsSortable = true)]
        public required string Title { get; privateset; }
        [JsonPropertyName("Content")]
        [SearchableField(IsFilterable = true, IsSortable = false)]
        public required string Content { get; privateset; }
        [JsonPropertyName("Url")]
        [SearchableField(IsFilterable = true, IsSortable = false)]
        public required string Url { get; privateset; }
    }
}
