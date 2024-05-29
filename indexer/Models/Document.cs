namespace Indexer.Models
{
    public class Document
    {
        public required Guid Id { private get; set; }
        public required string Title { private get; set; }
        public required string Content { private get; set; }
        public required string Url { private get; set; }
    }
}
