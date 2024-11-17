using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using HtmlAgilityPack;
using Indexer.Models;
using Microsoft.Extensions.Logging;

namespace Indexer.Services
{
    public class JwScrapper : IDisposable
    {
        public enum Language
        {
            EN,
            ES
        }

        private readonly static string BaseUrl = "https://wol.jw.org/";
        private readonly static int NumberOfBooks = 1;

        private readonly HttpClient _httpClient;
        private readonly ILogger _logger;

        public JwScrapper()
        {
            _httpClient = new HttpClient
            {
                BaseAddress = new Uri(BaseUrl)
            };
            _httpClient.DefaultRequestHeaders.Add("User-Agent", "JwScrapperBot/1.0");
            using ILoggerFactory factory = LoggerFactory.Create(builder => builder.AddConsole());
            _logger = factory.CreateLogger("Indexer");
        }

        public void Dispose()
        {
            _httpClient.Dispose();
            _logger.LogInformation("HttpClient disposed.");
        }

        public async Task ScrapeAsync(string path, Language language = Language.EN, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Starting scrape process. Language: {Language}, Output Path: {Path}", language, path);

            var bookParallelOptions = new ParallelOptions
            {
                MaxDegreeOfParallelism = Environment.ProcessorCount,
                CancellationToken = cancellationToken
            };

            try
            {
                await Parallel.ForEachAsync(
                    source: Enumerable.Range(1, NumberOfBooks),
                    parallelOptions: bookParallelOptions,
                    async (book, ctBook) =>
                    {
                        string bookName = book.ToString();
                        _logger.LogInformation("Starting to scrape Book {BookNumber}.", bookName);

                        try
                        {
                            string bookUrl = CreateBookUrl(bookName, language);
                            int numberOfChapters = await GetNumberOfChaptersAsync(bookUrl, ctBook);
                            _logger.LogInformation("Book {BookNumber} has {ChapterCount} chapters.", bookName, numberOfChapters);

                            var chapterParallelOptions = new ParallelOptions
                            {
                                MaxDegreeOfParallelism = Environment.ProcessorCount,
                                CancellationToken = ctBook
                            };

                            await Parallel.ForEachAsync(
                                source: Enumerable.Range(1, numberOfChapters),
                                parallelOptions: chapterParallelOptions,
                                async (chapter, ctChapter) =>
                                {
                                    _logger.LogInformation("Starting to scrape Chapter {ChapterNumber} of Book {BookNumber}.", chapter, bookName);

                                    try
                                    {
                                        string chapterUrl = CreateChapterUrl(bookName, chapter, language);
                                        int numberOfVerses = await GetNumberOfVersesAsync(chapterUrl, ctChapter);
                                        _logger.LogInformation("Chapter {ChapterNumber} of Book {BookNumber} has {VerseCount} verses.", chapter, bookName, numberOfVerses);

                                        var verseParallelOptions = new ParallelOptions
                                        {
                                            MaxDegreeOfParallelism = Environment.ProcessorCount,
                                            CancellationToken = ctChapter
                                        };

                                        await Parallel.ForEachAsync(
                                            source: Enumerable.Range(1, numberOfVerses),
                                            parallelOptions: verseParallelOptions,
                                            async (verse, ctVerse) =>
                                            {
                                                _logger.LogInformation("Scraping Verse {VerseNumber} of Chapter {ChapterNumber} in Book {BookNumber}.", verse, chapter, bookName);

                                                try
                                                {
                                                    PartialDocument verseDocument = await GetVerseAsync(chapterUrl, verse, ctVerse);
                                                    string json = JsonSerializer.Serialize(verseDocument);
                                                    string fileName = Path.Combine(path, $"{bookName}_{chapter}_{verse}.json");
                                                    await File.WriteAllTextAsync(fileName, json, ctVerse);
                                                    _logger.LogInformation("Successfully scraped and saved Verse {VerseNumber} of Chapter {ChapterNumber} in Book {BookNumber}.", verse, chapter, bookName);
                                                }
                                                catch (Exception ex)
                                                {
                                                    _logger.LogError(ex, "Error scraping Verse {VerseNumber} of Chapter {ChapterNumber} in Book {BookNumber}.", verse, chapter, bookName);
                                                }
                                            }
                                        );
                                    }
                                    catch (Exception ex)
                                    {
                                        _logger.LogError(ex, "Error scraping Chapter {ChapterNumber} of Book {BookNumber}.", chapter, bookName);
                                    }
                                }
                            );

                            _logger.LogInformation("Completed scraping Book {BookNumber}.", bookName);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Error scraping Book {BookNumber}.", bookName);
                        }
                    }
                );

                _logger.LogInformation("Scraping process completed successfully.");
            }
            catch (OperationCanceledException)
            {
                _logger.LogWarning("Scraping process was canceled.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unexpected error occurred during the scraping process.");
                throw;
            }
        }

        internal static string CreateBookUrl(string book, Language language)
        {
            return language switch
            {
                // Example URLs with chapter included
                // https://wol.jw.org/en/wol/binav/r1/lp-e/nwtsty/1/c1
                Language.EN => $"{BaseUrl}{language.ToString().ToLower()}/wol/binav/r1/lp-e/nwtsty/{book}",
                // https://wol.jw.org/es/wol/binav/r4/lp-s/nwt/66/c1
                Language.ES => $"{BaseUrl}{language.ToString().ToLower()}/wol/binav/r4/lp-s/nwt/{book}",
                _ => throw new ArgumentOutOfRangeException(nameof(language), language, null),
            };
        }

        internal static string CreateChapterUrl(string book, int chapter, Language language)
        {
            return language switch
            {
                // Example URLs with chapter included
                // https://wol.jw.org/en/wol/binav/r1/lp-e/nwtsty/1/c1
                Language.EN => $"{BaseUrl}{language.ToString().ToLower()}/wol/b/r1/lp-e/nwtsty/{book}/{chapter}",
                // https://wol.jw.org/es/wol/binav/r4/lp-s/nwt/66/c1
                Language.ES => $"{BaseUrl}{language.ToString().ToLower()}/wol/b/r4/lp-s/nwt/{book}/{chapter}",
                _ => throw new ArgumentOutOfRangeException(nameof(language), language, null),
            };
        }

        internal async Task<int> GetNumberOfChaptersAsync(string bookUrl, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Fetching number of chapters from URL: {BookUrl}", bookUrl);

            // Send HTTP GET request to the book URL
            var response = await _httpClient.GetAsync(bookUrl, cancellationToken);
            response.EnsureSuccessStatusCode();

            // Read the response content as a string
            var html = await response.Content.ReadAsStringAsync(cancellationToken);

            // Load the HTML into HtmlAgilityPack
            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            // Updated XPath to match <li> elements with both 'chapter' and 'gridItem' classes
            // and select their child <a> elements
            var chapterNodes = doc.DocumentNode.SelectNodes("//li[contains(@class, 'chapter') and contains(@class, 'gridItem')]/a");

            if (chapterNodes != null)
            {
                _logger.LogInformation("Found {ChapterCount} chapters at URL: {BookUrl}", chapterNodes.Count, bookUrl);
                return chapterNodes.Count;
            }

            _logger.LogWarning("Unable to determine the number of chapters at URL: {BookUrl}", bookUrl);
            throw new InvalidOperationException("Unable to determine the number of chapters.");
        }

        internal async Task<int> GetNumberOfVersesAsync(string chapterUrl, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Fetching number of verses from URL: {ChapterUrl}", chapterUrl);
            var response = await _httpClient.GetAsync(chapterUrl, cancellationToken);
            response.EnsureSuccessStatusCode();

            var html = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            // Updated XPath based on provided HTML structure
            var verseNodes = doc.DocumentNode.SelectNodes("//span[contains(@class, 'v')]/a[contains(@class, 'vx vp')]");

            if (verseNodes != null)
            {
                _logger.LogInformation("Found {VerseCount} verses at URL: {ChapterUrl}", verseNodes.Count, chapterUrl);
                return verseNodes.Count;
            }

            _logger.LogWarning("Unable to determine the number of verses at URL: {ChapterUrl}", chapterUrl);
            throw new InvalidOperationException("Unable to determine the number of verses.");
        }

        internal Task<string> GetVerseUrlAsync(string chapterUrl, int verse, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Constructing URL for Verse {VerseNumber} from Chapter URL: {ChapterUrl}", verse, chapterUrl);

            var uri = new Uri(chapterUrl);
            var segments = uri.Segments;

            if (segments.Length < 6)
            {
                _logger.LogError("Unexpected URL format: {ChapterUrl}", chapterUrl);
                throw new ArgumentException("Invalid chapter URL format.", nameof(chapterUrl));
            }

            string bookId = segments[5].TrimEnd('/');
            string verseNumberInBook = verse.ToString(); // Adjust if sequential numbering is required

            string verseUrl = $"{BaseUrl}en/wol/dx/r1/lp-e/{bookId}/{verseNumberInBook}";
            _logger.LogInformation("Constructed URL for Verse {VerseNumber}: {VerseUrl}", verse, verseUrl);
            return Task.FromResult(verseUrl);
        }

        internal async Task<string> GetVerseTextAsync(string chapterUrl, int verse, CancellationToken cancellationToken = default)
        {
            string verseUrl = await GetVerseUrlAsync(chapterUrl, verse, cancellationToken);
            _logger.LogInformation("Fetching text for Verse {VerseNumber} from URL: {VerseUrl}", verse, verseUrl);
            var response = await _httpClient.GetAsync(verseUrl, cancellationToken);
            response.EnsureSuccessStatusCode();

            var html = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            // Updated XPath based on provided HTML structure
            var verseNode = doc.DocumentNode.SelectSingleNode("//span[contains(@class, 'v')]/a[contains(@class, 'vx vp')]/following-sibling::text()");

            if (verseNode != null)
            {
                string verseText = HtmlEntity.DeEntitize(verseNode.InnerText.Trim());
                _logger.LogInformation("Retrieved text for Verse {VerseNumber}: {VerseText}", verse, verseText);
                return verseText;
            }

            _logger.LogWarning("Unable to retrieve text for Verse {VerseNumber} from URL: {VerseUrl}", verse, verseUrl);
            throw new InvalidOperationException($"Unable to retrieve text for verse {verse}.");
        }

        internal async Task<string> GetVerseTitleAsync(string chapterUrl, int verse, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Generating title for Verse {VerseNumber} from Chapter URL: {ChapterUrl}", verse, chapterUrl);

            var uri = new Uri(chapterUrl);
            var segments = uri.Segments;

            if (segments.Length < 7)
            {
                _logger.LogError("Unexpected URL format: {ChapterUrl}", chapterUrl);
                throw new ArgumentException("Invalid chapter URL format.", nameof(chapterUrl));
            }

            string bookId = segments[5].TrimEnd('/');
            string chapter = segments[6].TrimEnd('/');

            string bookName = await GetBookNameAsync(bookId, cancellationToken);

            string title = $"{bookName}:{chapter}:{verse}";
            _logger.LogInformation("Generated title for Verse {VerseNumber}: {Title}", verse, title);
            return title;
        }

        private Task<string> GetBookNameAsync(string bookId, CancellationToken cancellationToken)
        {
            // Implement a method to map bookId to book name.
            // This could be a lookup from a predefined dictionary or fetched from the website.

            // Example with a predefined dictionary
            var bookIdToName = new Dictionary<string, string>
    {
        { "1001070105", "Genesis" },
        // Add all necessary bookId mappings here
    };

            if (bookIdToName.TryGetValue(bookId, out var bookName))
            {
                return Task.FromResult(bookName);
            }

            _logger.LogWarning("Unknown bookId: {BookId}. Using 'Unknown Book'.", bookId);
            return Task.FromResult("Unknown Book");
        }

        internal async Task<PartialDocument> GetVerseAsync(string url, int verse, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Starting to get data for Verse {VerseNumber} from URL: {Url}", verse, url);

            var partialDocument = new PartialDocument
            {
                Title = await GetVerseTitleAsync(url, verse, cancellationToken),
                Content = await GetVerseTextAsync(url, verse, cancellationToken),
                Url = await GetVerseUrlAsync(url, verse, cancellationToken)
            };

            _logger.LogInformation("Completed getting data for Verse {VerseNumber}.", verse);
            return partialDocument;
        }
    }
}
