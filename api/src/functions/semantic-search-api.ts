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

        if (!serviceName || !apiKey || !indexName) {
            context.error(
                "Make sure to set valid values for endpoint, apiKey, and indexName in the environment variables"
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
            orderBy: ["@search.score desc"],
            select: ["id", "title", "content", "url"],
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
