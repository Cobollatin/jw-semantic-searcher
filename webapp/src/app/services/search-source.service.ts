import { HttpClient, HttpErrorResponse } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable, catchError, throwError } from "rxjs";
import { ComponentError, Document } from "../models";
import { environment } from "src/environments/environment";
import { PaginatedList } from "../models/paginated-list";

@Injectable({
    providedIn: "root",
})
export class SearchSourceService {
    constructor(private _httpClient: HttpClient) {}

    public searchSources(query: string): Observable<PaginatedList<Document>> {
        return this._httpClient
            .get<PaginatedList<Document>>(
                `${environment.apiUrl}/api/semantic-search?query=${query}`
            )
            .pipe(
                catchError((error: unknown) => {
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
