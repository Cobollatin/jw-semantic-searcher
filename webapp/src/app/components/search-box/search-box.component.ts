import { CommonModule } from "@angular/common";
import { Component, EventEmitter, OnDestroy, Output } from "@angular/core";
import {
    BehaviorSubject,
    debounceTime,
    filter,
    map,
    Observable,
    Subject,
    takeUntil,
    tap,
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
    private _searchTerm = new Subject<string>();
    private _unsubscribeAll = new Subject<void>();
    private _error = new BehaviorSubject<ComponentError | null>(null);

    public get error(): Observable<ComponentError | null> {
        return this._error.asObservable();
    }

    constructor() {
        this._searchTerm
            .pipe(
                debounceTime(500),
                map((term: string) => term.trim()),
                tap((term: string) => {
                    if (!term) {
                        this._error.next({
                            message: "Search term is empty",
                            code: 400,
                        });
                    } else if (term.length < 3) {
                        this._error.next({
                            message:
                                "Search term is too short (min 3 characters)",
                            code: 400,
                        });
                    } else {
                        this._error.next(null);
                    }
                }),
                filter((term: string) => term.length >= 3),
                map((term: string) => term.toLowerCase()),
                takeUntil(this._unsubscribeAll)
            )
            .subscribe((term: string) => {
                this.search.emit(term);
            });
    }

    public publishSearch(value: string): void {
        this._searchTerm.next(value);
    }

    public ngOnDestroy(): void {
        this._unsubscribeAll.next();
        this._unsubscribeAll.complete();
    }
}
