import { Component, Input } from "@angular/core";
import { CommonModule } from "@angular/common";
import { ComponentError, Document } from "src/app/models";

@Component({
    selector: "app-source-card",
    standalone: true,
    imports: [CommonModule],
    templateUrl: "./source-card.component.html",
    styleUrls: ["./source-card.component.css"],
})
export class SourceCardComponent {
    @Input() source?: Document;
    @Input() error?: ComponentError;

    constructor() {}

    public openLink(event: Event, url?: string): void {
        if (!url) {
            event.preventDefault();
            return;
        }
    }

    public formatPreview(preview?: string): string {
        if (!preview || preview.trim() === "") {
            return "This source has no preview.";
        }

        if (preview.length > 500) {
            return preview.substring(0, 500) + "...";
        }
        return preview;
    }

    public formatTitle(title?: string): string {
        if (!title || title.trim() === "") {
            return "Untitled";
        }

        if (title.length > 200) {
            return title.substring(0, 200) + "...";
        }
        return title;
    }
}
