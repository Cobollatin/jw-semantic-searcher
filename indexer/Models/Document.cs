using System.Text.Json.Serialization;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;

namespace Indexer.Models
{
    public class Document
    {
        [JsonPropertyName("Id")]
        [SimpleField(IsKey = true, IsFilterable = true, IsSortable = true)]
        public required string Id { get; init; }
        [JsonPropertyName("Title")]
        [SearchableField(IsFilterable = true, IsSortable = true, IsFacetable = false, AnalyzerName = LexicalAnalyzerName.Values.EnMicrosoft)]
        public required string Title { get; init; }
        [JsonPropertyName("Content")]
        [SearchableField(IsFilterable = true, IsSortable = false, IsFacetable = true, AnalyzerName = LexicalAnalyzerName.Values.EnMicrosoft)]
        public required string Content { get; init; }
        [JsonPropertyName("Url")]
        [SearchableField(IsFilterable = true, IsSortable = false, AnalyzerName = LexicalAnalyzerName.Values.Keyword)]
        public required string Url { get; init; }
        [JsonIgnore]
        public required IReadOnlyList<float> DescriptionVector { get; init; }
    }


        public class PartialDocument
    {
        [JsonPropertyName("Id")]
        public required string Id { get; init; }
        [JsonPropertyName("Title")]
        public required string Title { get; init; }
        [JsonPropertyName("Content")]
        public required string Content { get; init; }
        [JsonPropertyName("Url")]
        public required string Url { get; init; }
    }
}
