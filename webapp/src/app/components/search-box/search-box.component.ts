import { Component, EventEmitter, OnDestroy, Output } from "@angular/core";
import { CommonModule } from "@angular/common";
import {
    debounceTime,
    distinctUntilChanged,
    map,
    Subject,
    takeUntil,
    tap,
    throwIfEmpty,
} from "rxjs";
import { ComponentError } from "src/app/models";

@Component({
    selector: "app-search-box",
    standalone: true,
    imports: [CommonModule],
    templateUrl: "./search-box.component.html",
    styleUrls: ["./search-box.component.css"],
})
export class SearchBoxComponent implements OnDestroy {
    @Output() search = new EventEmitter<string>();
    private _searchTerm: Subject<string> = new Subject<string>();
    private _unsubscribeAll: Subject<null> = new Subject<null>();
    private _error?: ComponentError;

    public get error(): ComponentError | undefined {
        return this._error;
    }

    constructor() {
        this._searchTerm
            .pipe(
                debounceTime(500),
                map((term: string) => term.trim()),
                throwIfEmpty(() => {
                    throw {
                        message: "Search term is empty",
                        code: 400,
                    };
                }),
                map((term: string) => term.toLowerCase()),
                tap((term: string) => {
                    if (term.length < 3) {
                        throw {
                            message:
                                "Search term is too short (min 3 characters)",
                            code: 400,
                        };
                    }
                }),
                takeUntil(this._unsubscribeAll)
            )
            .subscribe({
                next: (term: string) => {
                    this.search.emit(term);
                    this._error = undefined;
                },
                error: (error: ComponentError) => {
                    this._error = error;
                    console.error(error);
                },
            });
    }

    public publichSearch(value: string): void {
        this._searchTerm.next(value);
    }

    public ngOnDestroy(): void {
        this._unsubscribeAll.next(null);
        this._unsubscribeAll.complete();
    }
}
