import { Component, Input } from "@angular/core";
import { CommonModule } from "@angular/common";
import { ComponentError, Source } from "src/app/models";

@Component({
    selector: "app-source-card",
    standalone: true,
    imports: [CommonModule],
    templateUrl: "./source-card.component.html",
    styleUrls: ["./source-card.component.css"],
})
export class SourceCardComponent {
    @Input() source?: Source;
    @Input() error?: ComponentError;

    constructor() {}

    public openLink(url: string): void {
        window.open(url, "_blank");
    }

    public formatPreview(preview: string) {
        if (preview === null || preview === undefined || preview === "") {
            return "This source has no preview";
        }

        if (preview.length > 100) {
            return preview.substring(0, 100) + "...";
        }
        return preview;
    }

    public formatTitle(title: string) {
        if (title.length > 50) {
            return title.substring(0, 50) + "...";
        }
        return title;
    }
}
