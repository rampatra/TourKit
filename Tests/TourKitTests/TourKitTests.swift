import Testing
@testable import TourKit

@Test func tourPageInitializationStoresValues() async throws {
    let page = TourPage(
        imageName: "feature-search",
        title: "All New Spotlight Search",
        description: "Find what you need instantly."
    )

    #expect(page.imageName == "feature-search")
    #expect(page.title == "All New Spotlight Search")
    #expect(page.description == "Find what you need instantly.")
}

@Test @MainActor
func slideshowCanBeCreatedWithPages() async throws {
    let pages = [
        TourPage(imageName: "one", title: "Welcome", description: "Welcome description"),
        TourPage(imageName: "two", title: "Search", description: "Search description")
    ]

    let view = TourSlideshowView(pages: pages)
    _ = view.body
}
