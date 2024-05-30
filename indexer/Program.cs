using Azure;
using Azure.Search.Documents.Indexes;
using Azure.Search.Documents.Indexes.Models;
using Indexer.Models;
using Indexer.Services;
using OpenAI_API;
using OpenAI_API.Embedding;
using OpenAI_API.Models;

string serviceName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SERVICE_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SERVICE_NAME");
string indexName = Environment.GetEnvironmentVariable("AZURE_SEARCH_INDEX_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_INDEX_NAME");
string apiKey = Environment.GetEnvironmentVariable("AZURE_SEARCH_API_KEY") ?? throw new ArgumentNullException("AZURE_SEARCH_API_KEY");
string semanticConfigName = Environment.GetEnvironmentVariable("AZURE_SEARCH_SEMANTIC_CONFIG_NAME") ?? throw new ArgumentNullException("AZURE_SEARCH_SEMANTIC_CONFIG_NAME");

var searchService = new AzureSearchService(serviceName, indexName, apiKey);

var fields = new FieldBuilder().Build(typeof(Document));
var SemanticSearch = new SemanticSearch
{
    Configurations =
    {
        new SemanticConfiguration(semanticConfigName, new()
        {
            TitleField = new SemanticField("Title"),
            ContentFields =
            {
                new SemanticField("Content")
            },
            KeywordsFields =
            {
                new SemanticField("Url")
            },
        })
    }
};
var vectorSearch = new VectorSearch
{
    Profiles = {
        new VectorSearchProfile(DocumentConstants.DocumentSearchProfile, semanticConfigName)
    },
    Algorithms = {
        new HnswAlgorithmConfiguration(semanticConfigName){
            Parameters = {
                    EfConstruction = 400,
                    EfSearch = 500,
                    M = 4,
                    Metric = VectorSearchAlgorithmMetric.Cosine
                }
        }
    }
};

var index = new SearchIndex(indexName)
{
    Fields = fields,
    SemanticSearch = SemanticSearch,
    VectorSearch = vectorSearch
};

string openAiKey = Environment.GetEnvironmentVariable("OPENAI_KEY") ?? throw new ArgumentNullException("OPENAI_KEY");
string deploymentName = Environment.GetEnvironmentVariable("OPENAI_DEPLOYMENT_NAME") ?? throw new ArgumentNullException("OPENAI_DEPLOYMENT_NAME");
string openAiOrgId = Environment.GetEnvironmentVariable("OPENAI_ORG_ID") ?? throw new ArgumentNullException("OPENAI_ORG_ID");
// string openAiOrgName = Environment.GetEnvironmentVariable("OPENAI_ORG_NAME") ?? throw new ArgumentNullException("OPENAI_ORG_NAME");
// string openAiProjectId = Environment.GetEnvironmentVariable("OPENAI_PROJECT_ID") ?? throw new ArgumentNullException("OPENAI_PROJECT_ID");
// string openAiProjectName = Environment.GetEnvironmentVariable("OPENAI_PROJECT_NAME") ?? throw new ArgumentNullException("OPENAI_PROJECT_NAME");
var openAIClient = new OpenAIAPI(new APIAuthentication(openAiKey, openAiOrgId));

CancellationTokenSource cancellationTokenSource = new();
CancellationToken cancellationToken = cancellationTokenSource.Token;

await searchService.DeleteIndexAsync(indexName, cancellationToken);
await searchService.CreateOrUpdateIndexAsync(index, cancellationToken);

var partialDocuments = new List<PartialDocument>
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
    new() { Id = "45", Title = "The Construction of the Great Wall of China", Content = "The Great Wall of China was built over several centuries, starting in the 7th century BC.", Url = "http://example.com/great_wall" },
    new() { Id = "46", Title = "The Publication of 'On the Origin of Species'", Content = "Charles Darwin published 'On the Origin of Species' in 1859, introducing the theory of evolution.", Url = "http://example.com/origin_of_species" },
    new() { Id = "47", Title = "The Storming of the Bastille", Content = "The Storming of the Bastille on July 14, 1789, marked the start of the French Revolution.", Url = "http://example.com/storming_of_bastille" },
    new() { Id = "48", Title = "The Birth of the United Nations", Content = "The United Nations was established on October 24, 1945, to promote international cooperation.", Url = "http://example.com/un_birth" },
    new() { Id = "49", Title = "The First Transatlantic Flight", Content = "Charles Lindbergh made the first solo nonstop transatlantic flight in 1927.", Url = "http://example.com/transatlantic_flight" },
    new() { Id = "50", Title = "The First Use of the Atomic Bomb", Content = "The United States dropped an atomic bomb on Hiroshima on August 6, 1945.", Url = "http://example.com/atomic_bomb" },
    new() { Id = "51", Title = "The Election of Nelson Mandela", Content = "Nelson Mandela was elected as South Africa's first black president in 1994.", Url = "http://example.com/mandela_election" },
    new() { Id = "52", Title = "The Fall of the Bastille", Content = "The Fall of the Bastille on July 14, 1789, was a pivotal event in the French Revolution.", Url = "http://example.com/bastille_fall" },
    new() { Id = "53", Title = "The Launch of Apollo 11", Content = "Apollo 11 launched on July 16, 1969, leading to the first moon landing.", Url = "http://example.com/apollo_11" },
    new() { Id = "54", Title = "The Battle of Thermopylae", Content = "The Battle of Thermopylae in 480 BC was a famous last stand of the Spartans.", Url = "http://example.com/thermopylae" },
    new() { Id = "55", Title = "The Signing of the Mayflower Compact", Content = "The Mayflower Compact was signed in 1620 by the Pilgrims, establishing self-governance.", Url = "http://example.com/mayflower_compact" },
    new() { Id = "56", Title = "The Assassination of Martin Luther King Jr.", Content = "Martin Luther King Jr. was assassinated on April 4, 1968, in Memphis, Tennessee.", Url = "http://example.com/mlk_assassination" },
    new() { Id = "57", Title = "The Invention of the Internet", Content = "The ARPANET, precursor to the internet, was created in 1969.", Url = "http://example.com/internet_invention" },
    new() { Id = "58", Title = "The Creation of the European Union", Content = "The European Union was formally established by the Maastricht Treaty in 1993.", Url = "http://example.com/eu_creation" },
    new() { Id = "59", Title = "The Independence of India", Content = "India gained independence from British rule on August 15, 1947.", Url = "http://example.com/india_independence" },
    new() { Id = "60", Title = "The Discovery of DNA Structure", Content = "James Watson and Francis Crick discovered the double helix structure of DNA in 1953.", Url = "http://example.com/dna_structure" },
    new() { Id = "61", Title = "The Cuban Revolution", Content = "The Cuban Revolution led by Fidel Castro ousted Batista in 1959.", Url = "http://example.com/cuban_revolution" },
    new() { Id = "62", Title = "The Prohibition Era", Content = "Prohibition in the United States lasted from 1920 to 1933, banning alcohol.", Url = "http://example.com/prohibition" },
    new() { Id = "63", Title = "The Berlin Blockade", Content = "The Berlin Blockade in 1948-1949 was an early Cold War confrontation.", Url = "http://example.com/berlin_blockade" },
    new() { Id = "64", Title = "The Establishment of NATO", Content = "The North Atlantic Treaty Organization was formed on April 4, 1949.", Url = "http://example.com/nato_establishment" },
    new() { Id = "65", Title = "The Invention of the Light Bulb", Content = "Thomas Edison invented the practical incandescent light bulb in 1879.", Url = "http://example.com/light_bulb" },
    new() { Id = "66", Title = "The Birth of William Shakespeare", Content = "William Shakespeare was born on April 23, 1564, in Stratford-upon-Avon.", Url = "http://example.com/shakespeare_birth" },
    new() { Id = "67", Title = "The Coronation of Queen Elizabeth II", Content = "Queen Elizabeth II was crowned on June 2, 1953.", Url = "http://example.com/queen_elizabeth_coronation" },
    new() { Id = "68", Title = "The Fall of Saigon", Content = "The Fall of Saigon on April 30, 1975, marked the end of the Vietnam War.", Url = "http://example.com/fall_of_saigon" },
    new() { Id = "69", Title = "The Ratification of the 19th Amendment", Content = "The 19th Amendment, granting women the right to vote, was ratified in 1920.", Url = "http://example.com/19th_amendment" },
    new() { Id = "70", Title = "The Wright Brothers' First Flight", Content = "On December 17, 1903, the Wright brothers achieved the first powered flight.", Url = "http://example.com/wright_brothers_flight" },
    new() { Id = "71", Title = "The Death of Alexander the Great", Content = "Alexander the Great died on June 10, 323 BC, marking the end of his empire.", Url = "http://example.com/alexander_death" },
    new() { Id = "72", Title = "The Salem Witch Trials", Content = "The Salem Witch Trials of 1692 were a series of hearings and prosecutions of people accused of witchcraft.", Url = "http://example.com/salem_witch_trials" },
    new() { Id = "73", Title = "The First Modern Olympics", Content = "The first modern Olympic Games were held in Athens, Greece, in 1896.", Url = "http://example.com/modern_olympics" },
    new() { Id = "74", Title = "The Rise of the Ming Dynasty", Content = "The Ming Dynasty began in 1368, marking a new era in Chinese history.", Url = "http://example.com/ming_dynasty" },
    new() { Id = "75", Title = "The Battle of Yorktown", Content = "The Battle of Yorktown in 1781 was the last major battle of the American Revolutionary War.", Url = "http://example.com/yorktown" },
    new() { Id = "76", Title = "The Discovery of Fire", Content = "The controlled use of fire by early humans was a turning point in human evolution.", Url = "http://example.com/fire_discovery" },
    new() { Id = "77", Title = "The Birth of Isaac Newton", Content = "Isaac Newton, a key figure in the scientific revolution, was born on January 4, 1643.", Url = "http://example.com/isaac_newton" },
    new() { Id = "78", Title = "The Battle of Stalingrad", Content = "The Battle of Stalingrad (1942-1943) was a major turning point in World War II.", Url = "http://example.com/stalingrad" },
    new() { Id = "79", Title = "The Publication of 'The Communist Manifesto'", Content = "Karl Marx and Friedrich Engels published 'The Communist Manifesto' in 1848.", Url = "http://example.com/communist_manifesto" },
    new() { Id = "80", Title = "The Reign of Queen Victoria", Content = "Queen Victoria reigned from 1837 to 1901, marking the Victorian era.", Url = "http://example.com/victoria_reign" },
    new() { Id = "81", Title = "The Execution of Marie Antoinette", Content = "Marie Antoinette was executed by guillotine on October 16, 1793.", Url = "http://example.com/marie_antoinette" },
    new() { Id = "82", Title = "The First Crusade", Content = "The First Crusade (1096-1099) was a military expedition by Western Christianity to regain the Holy Lands from Muslim control.", Url = "http://example.com/first_crusade" },
    new() { Id = "83", Title = "The Death of Cleopatra", Content = "Cleopatra, the last active ruler of the Ptolemaic Kingdom of Egypt, died in 30 BC.", Url = "http://example.com/cleopatra_death" },
    new() { Id = "84", Title = "The War of 1812", Content = "The War of 1812 was fought between the United States and the United Kingdom.", Url = "http://example.com/war_of_1812" },
    new() { Id = "85", Title = "The Publication of 'Don Quixote'", Content = "Miguel de Cervantes published 'Don Quixote', one of the most influential works of literature, in 1605.", Url = "http://example.com/don_quixote" },
    new() { Id = "86", Title = "The Construction of the Panama Canal", Content = "The Panama Canal, completed in 1914, revolutionized global trade routes.", Url = "http://example.com/panama_canal" },
    new() { Id = "87", Title = "The Great Chicago Fire", Content = "The Great Chicago Fire of 1871 destroyed a large part of the city.", Url = "http://example.com/chicago_fire" },
    new() { Id = "88", Title = "The Russian Revolution of 1905", Content = "The Russian Revolution of 1905 was a wave of mass political and social unrest that spread through vast areas of the Russian Empire.", Url = "http://example.com/revolution_1905" },
    new() { Id = "89", Title = "The Great Fire of London", Content = "The Great Fire of London in 1666 destroyed much of the city.", Url = "http://example.com/london_fire" },
    new() { Id = "90", Title = "The Death of Socrates", Content = "Socrates, the classical Greek philosopher, was executed in 399 BC.", Url = "http://example.com/socrates_death" },
    new() { Id = "91", Title = "The Signing of the Camp David Accords", Content = "The Camp David Accords were signed by Egypt and Israel in 1978, leading to a peace treaty.", Url = "http://example.com/camp_david" },
    new() { Id = "92", Title = "The Haitian Revolution", Content = "The Haitian Revolution (1791-1804) was a successful anti-slavery and anti-colonial insurrection.", Url = "http://example.com/haitian_revolution" },
    new() { Id = "93", Title = "The Construction of the Eiffel Tower", Content = "The Eiffel Tower was completed in 1889 and became a global icon of France.", Url = "http://example.com/eiffel_tower" },
    new() { Id = "94", Title = "The Battle of Trafalgar", Content = "The Battle of Trafalgar in 1805 was a naval engagement fought by the British Royal Navy against the combined fleets of France and Spain.", Url = "http://example.com/trafalgar" },
    new() { Id = "95", Title = "The Discovery of the Rosetta Stone", Content = "The Rosetta Stone, discovered in 1799, was key to deciphering Egyptian hieroglyphs.", Url = "http://example.com/rosetta_stone" },
    new() { Id = "96", Title = "The Great Migration", Content = "The Great Migration (1916-1970) was the movement of six million African Americans out of the rural Southern United States to the urban Northeast, Midwest, and West.", Url = "http://example.com/great_migration" },
    new() { Id = "97", Title = "The Birth of the Beatles", Content = "The Beatles, formed in Liverpool in 1960, revolutionized music and popular culture.", Url = "http://example.com/beatles" },
    new() { Id = "98", Title = "The Discovery of the Dead Sea Scrolls", Content = "The Dead Sea Scrolls, ancient Jewish texts, were discovered between 1946 and 1956.", Url = "http://example.com/dead_sea_scrolls" },
    new() { Id = "99", Title = "The Launch of the Hubble Space Telescope", Content = "The Hubble Space Telescope was launched into low Earth orbit in 1990 and has provided numerous discoveries.", Url = "http://example.com/hubble" },
    new() { Id = "100", Title = "The Invention of the Airplane", Content = "The Wright brothers made the first powered flight on December 17, 1903.", Url = "http://example.com/airplane_invention" }
};

var documents = new List<Document>();

foreach (var document in partialDocuments)
{
    var model = new Model(deploymentName);
    var descriptionVector = await openAIClient.Embeddings.GetEmbeddingsAsync("A test text for embedding", model);
    documents.Add(new Document
    {
        Id = document.Id,
        Title = document.Title,
        Content = document.Content,
        Url = document.Url,
        DescriptionVector = descriptionVector
    });
}

await searchService.UploadDocumentsAsync(documents, cancellationToken);

Console.WriteLine("Index updated successfully with mock data.");
