import { HttpClient, HttpErrorResponse } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable, catchError, of, throwError } from "rxjs";
import { environment } from "src/environments/environment";
import { ComponentError, Document } from "../models";

const MOCK_DOCUMENTS: Array<Document> = [
    {
        Id: "1",
        Title: "Title 1",
        Content: "Content 1",
        Url: "https://example.com/1",
    },
    {
        Id: "2",
        Title: "Title 2",
        Content: "Content 2",
        Url: "https://example.com/2",
    },
    {
        Id: "3",
        Title: "Title 3",
        Content: "Content 3",
        Url: "https://example.com/3",
    },
    {
        Id: "4",
        Title: "Title 4",
        Content: "Content 4",
        Url: "https://example.com/4",
    },
    {
        Id: "5",
        Title: "Title 5",
        Content: "Content 5",
        Url: "https://example.com/5",
    },
];

@Injectable({
    providedIn: "root",
})
export class SearchSourceService {
    constructor(private _httpClient: HttpClient) {}

    public searchSources(
        query: string,
        mock: boolean = false
    ): Observable<Array<Document>> {
        return this._httpClient
            .get<Array<Document>>(
                `${environment.apiUrl}/api/semantic-search?query=${query}`
            )
            .pipe(
                catchError((error: unknown) => {
                    if (mock) {
                        return of(MOCK_DOCUMENTS);
                    }

                    let errCode: number = 500;

                    if (error instanceof HttpErrorResponse) {
                        errCode = error.status;
                    }

                    return throwError((): ComponentError => {
                        return {
                            code: errCode,
                            message:
                                "An error occurred while searching for sources.",
                        };
                    });
                })
            );
    }
}
