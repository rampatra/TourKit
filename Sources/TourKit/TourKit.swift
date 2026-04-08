import SwiftUI

public struct TourPage: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let imageName: String
    public let imageBundle: Bundle?
    public let title: String
    public let description: String

    public init(
        id: UUID = UUID(),
        imageName: String,
        imageBundle: Bundle? = nil,
        title: String,
        description: String
    ) {
        self.id = id
        self.imageName = imageName
        self.imageBundle = imageBundle
        self.title = title
        self.description = description
    }
}

public struct TourSlideshowView: View {
    private let pages: [TourPage]
    private let continueButtonTitle: String
    private let finishButtonTitle: String
    private let onFinish: (() -> Void)?
    @State private var currentIndex: Int

    public init(
        pages: [TourPage],
        initialPageIndex: Int = 0,
        continueButtonTitle: String = "Continue",
        finishButtonTitle: String = "Done",
        onFinish: (() -> Void)? = nil
    ) {
        self.pages = pages
        self.continueButtonTitle = continueButtonTitle
        self.finishButtonTitle = finishButtonTitle
        self.onFinish = onFinish
        _currentIndex = State(initialValue: Self.clamped(initialPageIndex, pageCount: pages.count))
    }

    public var body: some View {
        Group {
            if pages.isEmpty {
                emptyState
            } else {
                VStack(spacing: 22) {
                    pageCarousel
                    pageDescription
                    controls
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentIndex)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack")
                .font(.title)
                .foregroundStyle(.secondary)
            Text("No tour pages")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }

    private var pageCarousel: some View {
        image(for: pages[currentIndex])
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 620, minHeight: 220, maxHeight: 360)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 380)
    }

    private var pageDescription: some View {
        let currentPage = pages[currentIndex]

        return VStack(spacing: 10) {
            PageIndicator(totalPages: pages.count, currentIndex: currentIndex)
            Text(currentPage.title)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
            Text(currentPage.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 560)
    }

    private var controls: some View {
        HStack(spacing: 10) {
            if currentIndex > 0 {
                Button("Back") { goBack() }
                    .buttonStyle(.bordered)
            }

            Button(isLastPage ? finishButtonTitle : continueButtonTitle) {
                advance()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
    }

    private var isLastPage: Bool {
        currentIndex == pages.count - 1
    }

    private static func clamped(_ index: Int, pageCount: Int) -> Int {
        guard pageCount > 0 else { return 0 }
        return max(0, min(index, pageCount - 1))
    }

    private func advance() {
        if isLastPage {
            onFinish?()
        } else {
            currentIndex += 1
        }
    }

    private func goBack() {
        currentIndex = max(0, currentIndex - 1)
    }

    private func image(for page: TourPage) -> Image {
        Image(page.imageName, bundle: page.imageBundle)
    }
}

public struct PageIndicator: View {
    private let totalPages: Int
    private let currentIndex: Int

    public init(totalPages: Int, currentIndex: Int) {
        self.totalPages = totalPages
        self.currentIndex = currentIndex
    }

    public var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == currentIndex ? Color.primary.opacity(0.9) : Color.secondary.opacity(0.35))
                    .frame(width: index == currentIndex ? 24 : 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentIndex + 1) of \(max(totalPages, 1))")
    }
}
