import {
    app,
    HttpFunctionOptions,
    HttpRequest,
    HttpResponseInit,
    InvocationContext,
} from "@azure/functions";
import { Document } from "../models";
import { AzureKeyCredential, SearchClient } from "@azure/search-documents";

const endpoint = process.env.AZURE_SEARCH_API_KEY || "";
const apiKey = process.env.AZURE_SEARCH_SERVICE_NAME || "";
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

        if (!endpoint || !apiKey) {
            console.error(
                "Make sure to set valid values for endpoint and apiKey with proper authorization."
            );
            return {
                status: 500,
            };
        }

        const credential = new AzureKeyCredential(apiKey);

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
        console.error(err);
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
