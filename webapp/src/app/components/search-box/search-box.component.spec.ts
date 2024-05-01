import { ComponentFixture, TestBed } from "@angular/core/testing";
import { SearchBoxComponent } from "./search-box.component";

describe("SearchBoxComponent", () => {
    let component: SearchBoxComponent;
    let fixture: ComponentFixture<SearchBoxComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [SearchBoxComponent],
        }).compileComponents();
    });

    beforeEach(() => {
        fixture = TestBed.createComponent(SearchBoxComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    afterEach(() => {
        fixture.destroy();
    });

    it("should emit search term when search is triggered", async () => {
        const searchTerm = "test";
        const searchSpy = jest.spyOn(component.search, "emit");
        component.publichSearch(searchTerm);
        await new Promise((resolve) => setTimeout(resolve, 500));
        expect(searchSpy).toHaveBeenCalledWith(searchTerm);
    });
});
