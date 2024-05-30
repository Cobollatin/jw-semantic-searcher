using System.Text.Json.Serialization;
using Azure.Search.Documents.Indexes;

namespace Indexer.Models
{
    public class Document
    {
        [JsonPropertyName("Id")]
        [SimpleField(IsKey = true, IsFilterable = true, IsSortable = true)]
        public required string Id { private get; set; }
        [JsonPropertyName("Title")]
        [SearchableField(IsFilterable = true, IsSortable = true)]
        public required string Title { private get; set; }
        [JsonPropertyName("Content")]
        [SearchableField(IsFilterable = true, IsSortable = false)]
        public required string Content { private get; set; }
        [JsonPropertyName("Url")]
        [SearchableField(IsFilterable = true, IsSortable = false)]
        public required string Url { private get; set; }
    }
}
