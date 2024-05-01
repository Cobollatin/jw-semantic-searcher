import { Component, Input } from "@angular/core";
import { CommonModule } from "@angular/common";
import { SourceCardComponent } from "../source-card/source-card.component";
import { ComponentError, Source } from "src/app/models";

@Component({
    selector: "app-source-search-results",
    standalone: true,
    imports: [CommonModule, SourceCardComponent],
    templateUrl: "./source-search-results.component.html",
    styleUrls: ["./source-search-results.component.css"],
})
export class SourceSearchResultsComponent {
    @Input() sources?: Source[] | null;

    constructor() {}

    getError(source: Source): ComponentError | undefined {
        if (source === undefined || source === null) {
            return {
                message: "Source is invalid",
                code: 400,
            };
        }

        if (
            source.title !== undefined ||
            source.title === null ||
            source.title === ""
        ) {
            return {
                message: "Source title is invalid",
                code: 400,
            };
        }

        return undefined;
    }

    hasError(source: Source): boolean {
        return this.getError(source) !== undefined;
    }
}
