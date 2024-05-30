export interface Document {
    Id: string;
    Title: string;
    Content: string;
    Url: string;
    DescriptionVector: number[];
}

export interface PartialDocument {
    Id: string;
    Title: string;
    Content: string;
    Url: string;
}
