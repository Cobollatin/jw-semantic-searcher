import { CommonModule } from "@angular/common";
import { Component } from "@angular/core";
import { SearchBoxComponent } from "./components/search-box/search-box.component";
import { SourceSearchResultsComponent } from "./components/source-search-results/source-search-results.component";
import { ComponentError, Document } from "./models";
import { SearchSourceService } from "./services/search-source.service";

@Component({
    standalone: true,
    imports: [SearchBoxComponent, SourceSearchResultsComponent, CommonModule],
    selector: "app-root",
    templateUrl: "./app.component.html",
    styleUrls: ["./app.component.css"],
    providers: [SearchSourceService],
})
/**
 * Represents the main component of the application.
 */
export class AppComponent {
    /**
     * The search term used for searching.
     */
    public searchTerm: string = "";
    /**
     * An array of Source objects.
     */
    public sources: Array<Document> = [];

    /**
     * Indicates whether the component is currently loading.
     */
    public loading: boolean = false;

    /**
     * Represents an error that can occur in the component.
     */
    public error?: ComponentError;

    /**
     * Indicates whether the component is ready or not.
     */
    public ready: boolean = false;

    /**
     * Represents the main component of the application.
     */
    constructor(private _searchSourceService: SearchSourceService) {}

    /**
     * Performs a search based on the provided event string.
     * @param $event - The event string to search for.
     */
    search($event: string) {
        this.loading = true;
        this.ready = false;
        this.error = undefined;
        this._searchSourceService.searchSources($event).subscribe({
            next: (sources: Array<Document>) => {
                this.sources = sources;
                this.loading = false;
                this.ready = true;
            },
            error: (error: ComponentError) => {
                this.error = error;
                this.loading = false;
                this.ready = false;
            },
        });
    }
}
