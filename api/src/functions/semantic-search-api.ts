// Recommended pattern
import {
    app,
    HttpFunctionOptions,
    HttpRequest,
    HttpResponseInit,
    InvocationContext,
} from "@azure/functions";
import { setTimeout } from "timers/promises";
import { Source } from "../models";

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
        context.log(`Performing source semantic search of: ${query}`);
        const fake_sources: Array<Source> = [
            {
                title: "The first source",
                preview: "The first source description",
                url: "https://www.google.com",
            },
            {
                title: "The second source",
                preview: "The second source description",
                url: "https://www.google.com",
            },
        ];
        return { body: JSON.stringify(fake_sources) };
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
