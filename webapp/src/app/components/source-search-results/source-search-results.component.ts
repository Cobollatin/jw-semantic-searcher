import { Component, Input } from "@angular/core";
import { CommonModule } from "@angular/common";
import { SourceCardComponent } from "../source-card/source-card.component";
import { ComponentError, Document } from "src/app/models";

@Component({
    selector: "app-source-search-results",
    standalone: true,
    imports: [CommonModule, SourceCardComponent],
    templateUrl: "./source-search-results.component.html",
    styleUrls: ["./source-search-results.component.css"],
})
export class SourceSearchResultsComponent {
    @Input() sources?: Document[] | null;

    constructor() {}

    getError(source: Document): ComponentError | undefined {
        if (source === undefined || source === null) {
            return {
                message: "Source is invalid",
                code: 400,
            };
        }

        if (
            source.Title !== undefined ||
            source.Title === null ||
            source.Title === ""
        ) {
            return {
                message: "Source title is invalid",
                code: 400,
            };
        }

        return undefined;
    }

    hasError(source: Document): boolean {
        return this.getError(source) !== undefined;
    }
}
