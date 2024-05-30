using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;
using Indexer.Models;
using Indexer.Services;

string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SERVICE_NAME");
string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_INDEX_NAME");
string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY") ?? throw new ArgumentNullException("AZURE_SEARCH_API_KEY");

var searchService = new AzureSearchService(serviceName, indexName, apiKey);

var index = new SearchIndex(indexName)
{
    Fields = new FieldBuilder().Build(typeof(Document)),
};

await searchService.CreateOrUpdateIndexAsync(index);

var documents = new List<Document>
{
    new() { Id = "1", Title = "The Fall of the Berlin Wall", Content = "On November 9, 1989, the Berlin Wall fell, marking the end of the Cold War.", Url = "http://example.com/berlin_wall" },
    new() { Id = "2", Title = "Moon Landing", Content = "On July 20, 1969, Neil Armstrong became the first human to walk on the moon.", Url = "http://example.com/moon_landing" },
    new() { Id = "3", Title = "The Declaration of Independence", Content = "The United States Declaration of Independence was signed on July 4, 1776.", Url = "http://example.com/declaration_of_independence" },
    new() { Id = "4", Title = "The Magna Carta", Content = "The Magna Carta was signed in 1215, limiting the power of the English monarchy.", Url = "http://example.com/magna_carta" },
    new() { Id = "5", Title = "The Wright Brothers' First Flight", Content = "On December 17, 1903, the Wright brothers achieved the first powered flight.", Url = "http://example.com/wright_brothers" },
    new() { Id = "6", Title = "The French Revolution", Content = "The French Revolution began in 1789, leading to the rise of modern democracy.", Url = "http://example.com/french_revolution" },
    new() { Id = "7", Title = "The Discovery of America", Content = "Christopher Columbus discovered America on October 12, 1492.", Url = "http://example.com/discovery_of_america" },
    new() { Id = "8", Title = "The Fall of Rome", Content = "The Western Roman Empire fell in AD 476.", Url = "http://example.com/fall_of_rome" },
    new() { Id = "9", Title = "The Russian Revolution", Content = "The Russian Revolution of 1917 led to the rise of the Soviet Union.", Url = "http://example.com/russian_revolution" },
    new() { Id = "10", Title = "The Invention of the Printing Press", Content = "Johannes Gutenberg invented the printing press around 1440.", Url = "http://example.com/printing_press" },
    new() { Id = "11", Title = "The Battle of Hastings", Content = "The Battle of Hastings in 1066 marked the Norman conquest of England.", Url = "http://example.com/battle_of_hastings" },
    new() { Id = "12", Title = "The Industrial Revolution", Content = "The Industrial Revolution began in the late 18th century in Britain.", Url = "http://example.com/industrial_revolution" },
    new() { Id = "13", Title = "The Assassination of Archduke Ferdinand", Content = "The assassination of Archduke Ferdinand in 1914 sparked World War I.", Url = "http://example.com/archduke_ferdinand" },
    new() { Id = "14", Title = "The Signing of the Treaty of Versailles", Content = "The Treaty of Versailles was signed on June 28, 1919, ending World War I.", Url = "http://example.com/treaty_of_versailles" },
    new() { Id = "15", Title = "The Stock Market Crash of 1929", Content = "The Stock Market Crash of October 29, 1929, led to the Great Depression.", Url = "http://example.com/stock_market_crash" },
    new() { Id = "16", Title = "The End of World War II", Content = "World War II ended on September 2, 1945, with the surrender of Japan.", Url = "http://example.com/end_of_ww2" },
    new() { Id = "17", Title = "The Attack on Pearl Harbor", Content = "The attack on Pearl Harbor on December 7, 1941, led the US to enter World War II.", Url = "http://example.com/pearl_harbor" },
    new() { Id = "18", Title = "The Cuban Missile Crisis", Content = "The Cuban Missile Crisis of 1962 was a major Cold War confrontation.", Url = "http://example.com/cuban_missile_crisis" },
    new() { Id = "19", Title = "The Fall of Constantinople", Content = "The Fall of Constantinople in 1453 marked the end of the Byzantine Empire.", Url = "http://example.com/fall_of_constantinople" },
    new() { Id = "20", Title = "The Renaissance", Content = "The Renaissance was a cultural movement that began in Italy in the 14th century.", Url = "http://example.com/renaissance" },
    new() { Id = "21", Title = "The Reformation", Content = "The Reformation was a 16th-century movement for the reform of the Catholic Church.", Url = "http://example.com/reformation" },
    new() { Id = "22", Title = "The Battle of Waterloo", Content = "The Battle of Waterloo in 1815 marked the end of Napoleon's rule.", Url = "http://example.com/battle_of_waterloo" },
    new() { Id = "23", Title = "The Signing of the Magna Carta", Content = "The Magna Carta was signed in 1215, establishing the principle of the rule of law.", Url = "http://example.com/magna_carta_signing" },
    new() { Id = "24", Title = "The Civil Rights Act of 1964", Content = "The Civil Rights Act of 1964 was a landmark law in the United States.", Url = "http://example.com/civil_rights_act" },
    new() { Id = "25", Title = "The Launch of Sputnik", Content = "The Soviet Union launched Sputnik, the first artificial satellite, on October 4, 1957.", Url = "http://example.com/sputnik" },
    new() { Id = "26", Title = "The Boston Tea Party", Content = "The Boston Tea Party in 1773 was a key event leading to the American Revolution.", Url = "http://example.com/boston_tea_party" },
    new() { Id = "27", Title = "The Battle of Gettysburg", Content = "The Battle of Gettysburg in 1863 was a turning point in the American Civil War.", Url = "http://example.com/battle_of_gettysburg" },
    new() { Id = "28", Title = "The Emancipation Proclamation", Content = "The Emancipation Proclamation was issued by Abraham Lincoln on January 1, 1863.", Url = "http://example.com/emancipation_proclamation" },
    new() { Id = "29", Title = "The Sinking of the Titanic", Content = "The Titanic sank on April 15, 1912, after hitting an iceberg.", Url = "http://example.com/titanic" },
    new() { Id = "30", Title = "The Louisiana Purchase", Content = "The Louisiana Purchase in 1803 doubled the size of the United States.", Url = "http://example.com/louisiana_purchase" },
    new() { Id = "31", Title = "The Assassination of JFK", Content = "President John F. Kennedy was assassinated on November 22, 1963.", Url = "http://example.com/jfk_assassination" },
    new() { Id = "32", Title = "The Signing of the Constitution", Content = "The United States Constitution was signed on September 17, 1787.", Url = "http://example.com/constitution_signing" },
    new() { Id = "33", Title = "The First Man in Space", Content = "Yuri Gagarin became the first man in space on April 12, 1961.", Url = "http://example.com/first_man_in_space" },
    new() { Id = "34", Title = "The End of the Cold War", Content = "The Cold War ended in 1991 with the dissolution of the Soviet Union.", Url = "http://example.com/end_of_cold_war" },
    new() { Id = "35", Title = "The Invention of the Telephone", Content = "Alexander Graham Bell invented the telephone in 1876.", Url = "http://example.com/telephone_invention" },
    new() { Id = "36", Title = "The California Gold Rush", Content = "The California Gold Rush began in 1848, attracting thousands to the West.", Url = "http://example.com/gold_rush" },
    new() { Id = "37", Title = "The First Flight", Content = "On December 17, 1903, the Wright brothers made their first powered flight.", Url = "http://example.com/first_flight" },
    new() { Id = "38", Title = "The Berlin Airlift", Content = "The Berlin Airlift of 1948-1949 supplied West Berlin amidst a Soviet blockade.", Url = "http://example.com/berlin_airlift" },
    new() { Id = "39", Title = "The Battle of Midway", Content = "The Battle of Midway in 1942 was a turning point in the Pacific Theater of World War II.", Url = "http://example.com/battle_of_midway" },
    new() { Id = "40", Title = "The Normandy Invasion", Content = "The Normandy Invasion on June 6, 1944, was a pivotal moment in World War II.", Url = "http://example.com/normandy_invasion" },
    new() { Id = "41", Title = "The First Computer", Content = "The ENIAC, the first general-purpose computer, was completed in 1945.", Url = "http://example.com/first_computer" },
    new() { Id = "42", Title = "The Black Death", Content = "The Black Death killed an estimated 25 million people in Europe between 1347 and 1351.", Url = "http://example.com/black_death" },
    new() { Id = "43", Title = "The Assassination of Julius Caesar", Content = "Julius Caesar was assassinated on March 15, 44 BC, a turning point in Roman history.", Url = "http://example.com/caesar_assassination" },
    new() { Id = "44", Title = "The Discovery of Penicillin", Content = "Alexander Fleming discovered penicillin in 1928, revolutionizing medicine.", Url = "http://example.com/penicillin" },
    new() { Id = "45", Title = "The Construction of the Great Wall of China", Content = "The Great Wall of China was built over several centuries, starting in the 7th century BC.", Url = "http://example.com/great_wall" }
};

await searchService.UploadDocumentsAsync(documents);

Console.WriteLine("Index updated successfully with mock data.");
