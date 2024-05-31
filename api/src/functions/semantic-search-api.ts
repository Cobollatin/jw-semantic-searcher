import {
    app,
    HttpFunctionOptions,
    HttpRequest,
    HttpResponseInit,
    InvocationContext,
} from "@azure/functions";
import { Document, PartialDocument } from "../models";
import { AzureKeyCredential, SearchClient } from "@azure/search-documents";
import OpenAI from "openai";
import { PaginatedList } from "../models/paginated-list";

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
        const page = parseInt(request.query.get("page") ?? "1");
        const pageSize = parseInt(request.query.get("pageSize") ?? "10");

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

        const searchResults = await searchClient.search(query, {
            includeTotalCount: true,
            select: ["Id", "Title", "Content", "Url"],
            facets: ["Content"],
            // queryType: "semantic",
            queryType: "full",
            top: pageSize,
            skip: pageSize * (page - 1),
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
            // semanticSearchOptions: {
            //     configurationName: semanticSearchConfig,
            //     errorMode: "partial",
            //     maxWaitInMilliseconds: 5000,
            //     answers: {
            //         answerType: "extractive",
            //         count: 1,
            //         threshold: 0.7,
            //     },
            //     captions: {
            //         captionType: "extractive",
            //         highlight: true,
            //     },
            // },
        });

        const results: Array<PartialDocument> = new Array<PartialDocument>();
        for await (const result of searchResults.results) {
            results.push(result.document);
        }

        const response: PaginatedList<PartialDocument> = {
            items: results,
            total: searchResults.count ?? 0,
            page: page,
            pageSize: pageSize,
        };

        return { body: JSON.stringify(response) };
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
