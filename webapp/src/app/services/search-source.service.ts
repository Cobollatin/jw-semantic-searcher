import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable, catchError, throwError } from "rxjs";
import { ComponentError, Source } from "../models";
import { environment } from "src/environments/environment";

@Injectable({
    providedIn: "root",
})
export class SearchSourceService {
    constructor(private _httpClient: HttpClient) {}

    public searchSources(query: string): Observable<Source[]> {
        return this._httpClient
            .get<Source[]>(
                `${environment.apiUrl}/api/source-semantic-search?query=${query}`
            )
            .pipe(
                catchError((error: unknown) => {
                    console.error("Handle");
                    return throwError((): ComponentError => {
                        return {
                            code: 500,
                            message:
                                "An error occurred while searching for sources.",
                        };
                    });
                })
            );
    }
}
