import {
    app,
    HttpFunctionOptions,
    HttpRequest,
    HttpResponseInit,
    InvocationContext,
} from "@azure/functions";
import { Document } from "../models";
import { AzureKeyCredential, SearchClient } from "@azure/search-documents";
import OpenAI from "openai";

const serviceName = process.env.AZURE_SEARCH_SERVICE_NAME || "";
const apiKey = process.env.AZURE_SEARCH_API_KEY || "";
const indexName = process.env.AZURE_SEARCH_INDEX_NAME || "";
const semanticSearchConfig =
    process.env.AZURE_SEARCH_SEMANTIC_CONFIG_NAME || "";

const openAiKey = process.env["OPENAI_KEY"] || "";
const openAiOrgName = process.env["OPENAI_ORG_NAME"] || "";
const openAiOrgId = process.env["OPENAI_ORG_ID"] || "";
const openAiProjectName = process.env["OPENAI_PROJECT_NAME"] || "";
const openAiProjectId = process.env["OPENAI_PROJECT_ID"] || "";
const deploymentName = process.env["OPENAI_DEPLOYMENT_NAME"] || "";

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

        if (
            !openAiKey ||
            !openAiOrgName ||
            !openAiOrgId ||
            !openAiProjectName ||
            !openAiProjectId ||
            !deploymentName
        ) {
            context.error(
                "Make sure to set valid values for OPENAI_KEY, OPENAI_ORG, OPENAI_PROJECT, OPENAI_DEPLOYMENT_NAME in your environment variables."
            );
            return {
                status: 500,
            };
        }

        const searchServiceCredentials = new AzureKeyCredential(apiKey);
        const searchServiceEndpoint = `https://${serviceName}.search.windows.net`;

        const searchClient: SearchClient<Document> = new SearchClient<Document>(
            searchServiceEndpoint,
            indexName,
            searchServiceCredentials
        );

        const openAiClient = new OpenAI({
            apiKey: openAiKey,
            project: openAiProjectId,
            organization: openAiOrgId,
        });
        const embeddings = await openAiClient.embeddings.create({
            input: query,
            model: deploymentName,
        });

        const searchResults = await searchClient.search(query, {
            includeTotalCount: true,
            // Order by is not supported for semantic search
            // orderBy: ["search.score() desc"],
            select: ["Id", "Title", "Content", "Url"],
            facets: ["Content"],
            queryType: "semantic",
            vectorSearchOptions: {
                filterMode: "preFilter",
                queries: [
                    {
                        kind: "vector",
                        kNearestNeighborsCount: 3,
                        exhaustive: false,
                        fields: ["Content"],
                        vector: embeddings.data[0].embedding,
                    },
                ],
            },
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
