import {
    app,
    HttpFunctionOptions,
    HttpRequest,
    HttpResponseInit,
    InvocationContext,
} from "@azure/functions";
import { Document } from "../models";
import { AzureKeyCredential, SearchClient } from "@azure/search-documents";

const serviceName = process.env.AZURE_SEARCH_SERVICE_NAME || "";
const apiKey = process.env.AZURE_SEARCH_API_KEY || "";
const indexName = process.env.AZURE_SEARCH_INDEX_NAME || "";
const semanticSearchConfig =
    process.env.AZURE_SEARCH_SEMANTIC_CONFIG_NAME || "";

export async function getSourceSemanticSearch(
    request: HttpRequest,
    context: InvocationContext
): Promise<HttpResponseInit> {
    try {
        const query = request.query.get("query");
        if (!query) {
            return {
                status: 400,
            };
        }

        if (!serviceName || !apiKey || !indexName || !semanticSearchConfig) {
            context.error(
                "Make sure to set valid values for endpoint, apiKey, indexName, and semanticSearchConfig in your environment variables."
            );
            return {
                status: 500,
            };
        }

        const credential = new AzureKeyCredential(apiKey);
        const endpoint = `https://${serviceName}.search.windows.net`;

        const searchClient: SearchClient<Document> = new SearchClient<Document>(
            endpoint,
            indexName,
            credential
        );

        const searchResults = await searchClient.search(query, {
            includeTotalCount: true,
            // Order by is not supported for semantic search
            // orderBy: ["search.score() desc"],
            select: ["Id", "Title", "Content", "Url"],
            queryType: "semantic",
            semanticSearchOptions: {
                configurationName: semanticSearchConfig,
                errorMode: "partial",
                maxWaitInMilliseconds: 5000,
                answers: {
                    answerType: "extractive",
                    count: 1,
                    threshold: 0.5,
                },
                captions: {
                    captionType: "extractive",
                    highlight: true,
                },
            },
        });

        const results: Array<Document> = new Array<Document>();
        for await (const result of searchResults.results) {
            results.push(result.document);
        }

        return { body: JSON.stringify(results) };
    } catch (err) {
        context.error(err);
        // This rethrown exception will only fail the individual invocation, instead of crashing the whole process
        throw err;
    }
}

const options: HttpFunctionOptions = {
    route: "source-semantic-search",
    methods: ["GET"],
    authLevel: "anonymous",
    handler: getSourceSemanticSearch,
};

app.http("semanticSearchApi", options);
