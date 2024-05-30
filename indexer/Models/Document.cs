using System.Text.Json.Serialization;
using Azure.Search.Documents.Indexes;

namespace Indexer.Models
{
    public class Document
    {
        [JsonPropertyName("HotelId")]
        [SimpleField(IsKey = true, IsFilterable = true, IsSortable = true)]
        public required string Id { private get; set; }
        [JsonPropertyName("HotelName")]
        [SearchableField(IsFilterable = true, IsSortable = true)]
        public required string Title { private get; set; }
        [JsonPropertyName("HotelName")]
        [SearchableField(IsFilterable = true, IsSortable = false)]
        public required string Content { private get; set; }
        [JsonPropertyName("HotelName")]
        [SearchableField(IsFilterable = true, IsSortable = false)]
        public required string Url { private get; set; }
    }
}
