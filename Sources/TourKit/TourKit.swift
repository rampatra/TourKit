import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

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
    private let onClose: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int

    public init(
        pages: [TourPage],
        initialPageIndex: Int = 0,
        continueButtonTitle: String = "Continue",
        finishButtonTitle: String = "Done",
        onFinish: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.pages = pages
        self.continueButtonTitle = continueButtonTitle
        self.finishButtonTitle = finishButtonTitle
        self.onFinish = onFinish
        self.onClose = onClose
        _currentIndex = State(initialValue: Self.clamped(initialPageIndex, pageCount: pages.count))
    }

    public var body: some View {
        Group {
            if pages.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    imageSection
                    bottomPanel
                }
                .background(Color(white: 0.10))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentIndex)
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

    // MARK: - Image section (top ~55%)

    private var imageSection: some View {
        ZStack(alignment: .top) {
            image(for: pages[currentIndex])
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: Color(white: 0.10).opacity(0.5), location: 0.55),
                            .init(color: Color(white: 0.10), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                    .allowsHitTesting(false)
                }

            topControls
        }
    }

    // MARK: - Bottom panel (dark area with text + button)

    private var bottomPanel: some View {
        let currentPage = pages[currentIndex]

        return VStack(spacing: 12) {
            PageIndicator(totalPages: pages.count, currentIndex: currentIndex)
                .padding(.bottom, 4)

            Text(currentPage.title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text(currentPage.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)

            primaryActionButton
                .padding(.top, 6)
        }
        .padding(.horizontal, 32)
        .padding(.top, 6)
        .padding(.bottom, 24)
    }

    // MARK: - Top controls (back / close overlaying the image)

    private var topControls: some View {
        HStack {
            iconButton(systemName: "chevron.left") {
                goBack()
            }
            .opacity(currentIndex > 0 ? 1 : 0)

            Spacer()

            iconButton(systemName: "checkmark") {
                if let onClose {
                    onClose()
                } else {
                    dismiss()
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
    }

    // MARK: - Primary CTA

    private var primaryActionButton: some View {
        Button(action: advance) {
            Text(isLastPage ? finishButtonTitle : continueButtonTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 220, height: 42)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.10, green: 0.60, blue: 1.0),
                                    Color(red: 0.04, green: 0.46, blue: 0.96)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .clipShape(Capsule(style: .continuous))
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.defaultAction)
    }

    // MARK: - Icon button (glass circle)

    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 32, height: 32)
                .background {
                    if #available(macOS 26.0, iOS 26.0, *) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle().stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                            }
                    } else {
                        Circle().fill(Color.white.opacity(0.15))
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
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
            if let onFinish {
                onFinish()
            } else if let onClose {
                onClose()
            } else {
                dismiss()
            }
        } else {
            currentIndex += 1
        }
    }

    private func goBack() {
        currentIndex = max(0, currentIndex - 1)
    }

    private func image(for page: TourPage) -> Image {
        if let bundle = page.imageBundle,
           let image = platformImage(named: page.imageName, in: bundle) {
            #if canImport(AppKit)
            return Image(nsImage: image)
            #elseif canImport(UIKit)
            return Image(uiImage: image)
            #else
            return Image(page.imageName, bundle: page.imageBundle)
            #endif
        }

        return Image(page.imageName, bundle: page.imageBundle)
    }

    #if canImport(AppKit)
    private func platformImage(named name: String, in bundle: Bundle) -> NSImage? {
        if let direct = bundle.image(forResource: name) {
            return direct
        }

        let nsName = NSImage.Name((name as NSString).deletingPathExtension)
        if let catalogImage = bundle.image(forResource: nsName) {
            return catalogImage
        }

        return loadImageFromResourceFile(named: name, in: bundle)
    }
    #elseif canImport(UIKit)
    private func platformImage(named name: String, in bundle: Bundle) -> UIImage? {
        if let direct = UIImage(named: name, in: bundle, compatibleWith: nil) {
            return direct
        }

        return loadImageFromResourceFile(named: name, in: bundle)
    }
    #endif

    #if canImport(AppKit)
    private func loadImageFromResourceFile(named name: String, in bundle: Bundle) -> NSImage? {
        if let resourceURL = resourceURL(named: name, in: bundle) {
            return NSImage(contentsOf: resourceURL)
        }
        return nil
    }
    #elseif canImport(UIKit)
    private func loadImageFromResourceFile(named name: String, in bundle: Bundle) -> UIImage? {
        guard let resourceURL = resourceURL(named: name, in: bundle),
              let data = try? Data(contentsOf: resourceURL) else {
            return nil
        }
        return UIImage(data: data)
    }
    #endif

    private func resourceURL(named name: String, in bundle: Bundle) -> URL? {
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension
        if !ext.isEmpty, let url = bundle.url(forResource: base, withExtension: ext) {
            return url
        }

        for candidateExt in ["png", "jpg", "jpeg", "heic", "tiff", "gif", "webp"] {
            if let url = bundle.url(forResource: name, withExtension: candidateExt) {
                return url
            }
        }

        return nil
    }
}

#if canImport(AppKit)

/// Presents a `TourSlideshowView` inside a transparent, card-sized, draggable macOS window.
///
/// The window has no title bar, no visible chrome, a transparent background, and is sized
/// to match the tour card. It can be dragged around by its background and participates in
/// Mission Control / App Exposé like a normal window.
@MainActor
public final class TourKitWindowController {
    private final class HostWindow: NSWindow {
        override var canBecomeKey: Bool { true }
        override var canBecomeMain: Bool { true }
    }

    private var window: NSWindow?
    private var windowDelegate: WindowDelegate?

    public init() {}

    /// Presents the tour window. If a window is already visible, it is brought to the front.
    ///
    /// The window automatically closes when the user taps the checkmark or finishes the tour.
    /// `onClose` and `onFinish` are invoked *before* the window is dismissed.
    @discardableResult
    public func present(
        pages: [TourPage],
        width: CGFloat = 660,
        continueButtonTitle: String = "Continue",
        finishButtonTitle: String = "Done",
        onFinish: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) -> NSWindow {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return existing
        }

        let dismiss: () -> Void = { [weak self] in
            self?.close()
        }

        let rootView = TourSlideshowView(
            pages: pages,
            continueButtonTitle: continueButtonTitle,
            finishButtonTitle: finishButtonTitle,
            onFinish: {
                if let onFinish {
                    onFinish()
                } else {
                    onClose?()
                }
                dismiss()
            },
            onClose: {
                onClose?()
                dismiss()
            }
        )
        .frame(width: width)

        let hosting = NSHostingView(rootView: rootView)
        if #available(macOS 13.0, *) {
            hosting.sizingOptions = [.intrinsicContentSize]
        }
        hosting.layoutSubtreeIfNeeded()
        let contentSize = CGSize(
            width: width,
            height: max(hosting.fittingSize.height, 1)
        )
        hosting.frame = NSRect(origin: .zero, size: contentSize)

        let window = HostWindow(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.collectionBehavior = [.managed, .participatesInCycle, .fullScreenAuxiliary]
        window.contentView = hosting
        window.center()

        let delegate = WindowDelegate { [weak self] in
            self?.window = nil
            self?.windowDelegate = nil
        }
        window.delegate = delegate
        self.windowDelegate = delegate

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
        return window
    }

    /// Closes the tour window if it is currently presented.
    public func close() {
        window?.close()
        window = nil
        windowDelegate = nil
    }

    private final class WindowDelegate: NSObject, NSWindowDelegate {
        let onClose: () -> Void
        init(onClose: @escaping () -> Void) { self.onClose = onClose }
        func windowWillClose(_ notification: Notification) { onClose() }
    }
}

#endif

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
                    .fill(index == currentIndex ? Color.white.opacity(0.95) : Color.white.opacity(0.32))
                    .frame(width: index == currentIndex ? 24 : 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentIndex + 1) of \(max(totalPages, 1))")
    }
}
