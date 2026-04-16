import SwiftUI
import TourKit
#if os(macOS)
import AppKit
#endif

@main
struct TourKitSampleApp: App {
    var body: some Scene {
        WindowGroup("TourKit Sample") {
            SampleTourScreen()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
#if os(macOS)
                .background(WindowConfigurator())
#endif
        }
        .windowStyle(.hiddenTitleBar)
    }
}

private struct SampleTourScreen: View {
    private let pages: [TourPage] = [
        TourPage(
            imageName: "app-store-all",
            imageBundle: .module,
            title: "Take your presentation skills to the next level",
            description: "Annotate, highlight, spotlight, and zoom in real-time."
        ),
        TourPage(
            imageName: "app-store-cursor-all",
            imageBundle: .module,
            title: "Cursor spotlight, highlight, and zoom",
            description: "Guide attention clearly so your audience never misses context."
        ),
        TourPage(
            imageName: "app-store-annotate-ipad",
            imageBundle: .module,
            title: "Draw with your iPad",
            description: "Mirror to iPad and annotate naturally with Apple Pencil."
        ),
        TourPage(
            imageName: "app-store-annotate-real-time",
            imageBundle: .module,
            title: "Annotate your screen in real-time",
            description: "Use it live on calls and presentations across meeting apps."
        ),
        TourPage(
            imageName: "app-store-annotate-key-shortcuts",
            imageBundle: .module,
            title: "Configure custom key shortcuts",
            description: "Set shortcut combinations for fast, repeatable actions."
        ),
    ]

    var body: some View {
        ZStack {
            Color.clear
            TourSlideshowView(
                pages: pages,
                continueButtonTitle: "Continue",
                finishButtonTitle: "Get Started",
                onClose: closeWindow
            )
            .frame(width: 660, height: 640)
            .shadow(color: .black.opacity(0.55), radius: 40, y: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func closeWindow() {
#if os(macOS)
        NSApplication.shared.terminate(nil)
#endif
    }
}

#if os(macOS)
private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.styleMask.insert(.fullSizeContentView)
            window.styleMask.remove(.resizable)
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovable = false
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            if let screen = window.screen ?? NSScreen.main {
                window.setFrame(screen.frame, display: true)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
