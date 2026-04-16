import SwiftUI
import TourKit
#if os(macOS)
import AppKit
#endif

@main
struct TourKitSampleApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor(SampleAppDelegate.self) private var appDelegate
#endif

    var body: some Scene {
#if os(macOS)
        Settings { EmptyView() }
#else
        WindowGroup("TourKit Sample") {
            TourSlideshowView(pages: SampleTour.pages)
        }
#endif
    }
}

enum SampleTour {
    static let pages: [TourPage] = [
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
}

#if os(macOS)
@MainActor
final class SampleAppDelegate: NSObject, NSApplicationDelegate {
    private let tour = TourKitWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        tour.present(
            pages: SampleTour.pages,
            continueButtonTitle: "Continue",
            finishButtonTitle: "Get Started",
            onClose: {
                NSApp.terminate(nil)
            }
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
#endif
