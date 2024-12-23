import {
    app,
    HttpFunctionOptions,
    HttpRequest,
    HttpResponseInit,
    InvocationContext,
} from "@azure/functions";
import {
    AzureKeyCredential,
    SearchClient,
    SearchDocumentsResult,
} from "@azure/search-documents";
import OpenAI from "openai";
import { Document, PartialDocument } from "../models";

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

const enableSemanticSearch = process.env["ENABLE_SEMANTIC_SEARCH"] || "false";

export async function getSourceSemanticSearch(
    request: HttpRequest,
    context: InvocationContext
): Promise<HttpResponseInit> {
    try {
        const query = request.query.get("query");

        if (!query) {
            return {
                status: 400,
                body: JSON.stringify({
                    error: "Query parameter is required.",
                }),
            };
        }

        if (!serviceName || !apiKey || !indexName || !semanticSearchConfig) {
            context.error(
                "Make sure to set valid values for endpoint, apiKey, indexName, and semanticSearchConfig in your environment variables."
            );
            return {
                status: 500,
                body: JSON.stringify({
                    error: "Invalid search service configuration. Please check the server logs.",
                }),
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
                body: JSON.stringify({
                    error: "Invalid OpenAI configuration. Please check the server logs.",
                }),
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

        let searchResults: SearchDocumentsResult<
            Document,
            "Id" | "Title" | "Content" | "Url"
        >;

        if (enableSemanticSearch === "true") {
            searchResults = await searchClient.search(query, {
                includeTotalCount: false,
                select: ["Id", "Title", "Content", "Url"],
                facets: ["Content"],
                queryType: "semantic",
                top: 25,
                skip: 0,
                vectorSearchOptions: {
                    filterMode: "preFilter",
                    queries: [
                        {
                            kind: "vector",
                            kNearestNeighborsCount: 3,
                            exhaustive: false,
                            fields: ["DescriptionVector"],
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
                        threshold: 0.7,
                    },
                    captions: {
                        captionType: "extractive",
                        highlight: true,
                    },
                },
            });
        } else {
            searchResults = await searchClient.search(query, {
                includeTotalCount: false,
                select: ["Id", "Title", "Content", "Url"],
                facets: ["Content"],
                queryType: "full",
                top: 25,
                skip: 0,
                vectorSearchOptions: {
                    filterMode: "preFilter",
                    queries: [
                        {
                            kind: "vector",
                            kNearestNeighborsCount: 3,
                            exhaustive: false,
                            fields: ["DescriptionVector"],
                            vector: embeddings.data[0].embedding,
                        },
                    ],
                },
            });
        }

        const results: Array<PartialDocument> = new Array<PartialDocument>();
        for await (const result of searchResults.results) {
            results.push(result.document);
        }

        return { body: JSON.stringify(results) };
    } catch (err) {
        context.error(err);
        return {
            status: 500,
            body: JSON.stringify({
                error: "An error occurred while processing the request.",
            }),
        };
    }
}

const options: HttpFunctionOptions = {
    route: "semantic-search",
    methods: ["GET"],
    authLevel: "anonymous",
    handler: getSourceSemanticSearch,
};

app.http("semanticSearchApi", options);
