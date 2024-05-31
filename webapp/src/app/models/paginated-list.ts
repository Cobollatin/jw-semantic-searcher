export interface PaginatedList<T> {
    items: Array<T>;
    total: number;
    page: number;
    pageSize: number;
}
