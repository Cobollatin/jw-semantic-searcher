using System.Text.Json.Serialization;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;

namespace Indexer.Models
{
    public static class DocumentConstants
    {
        public const string DocumentSearchProfile = "semantic-search-config";
        public const int DescriptionVectorDimension = 1536;
    }

    public class Document
    {
        [SimpleField(IsKey = true, IsFilterable = true, IsSortable = true)]
        public required string Id { get; init; }
        [SearchableField(IsFilterable = true, IsSortable = true, IsFacetable = false, AnalyzerName = LexicalAnalyzerName.Values.EnMicrosoft)]
        public required string Title { get; init; }
        [SearchableField(IsFilterable = true, IsSortable = false, IsFacetable = true, AnalyzerName = LexicalAnalyzerName.Values.EnMicrosoft)]
        public required string Content { get; init; }
        [SearchableField(IsFilterable = true, IsSortable = false, AnalyzerName = LexicalAnalyzerName.Values.Keyword)]
        public required string Url { get; init; }
        [VectorSearchField(VectorSearchDimensions = DocumentConstants.DescriptionVectorDimension, VectorSearchProfileName = DocumentConstants.DocumentSearchProfile)]
        public IReadOnlyList<float>? DescriptionVector { get; set; }

        override public string ToString()
        {
            return $"Id: {Id}, Title: {Title.PadRight(10, '\0')[..10]}, Content: {Content.PadRight(20, '\0')[..20]}, Url: {Url}, DescriptionVector: {DescriptionVector?.Count ?? 0} dimensions";
        }
    }


    public class PartialDocument
    {
        public required string Id { get; init; }
        public required string Title { get; init; }
        public required string Content { get; init; }
        public required string Url { get; init; }
    }
}
