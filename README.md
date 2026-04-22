# TourKit

TourKit is a Swift Package that provides a SwiftUI slideshow view for feature walkthroughs and onboarding flows, plus a ready-to-use floating window controller on macOS.

## Demo

https://github.com/user-attachments/assets/6a2379e7-d0ce-40a6-bae0-37b4d9573917

## Features

- **Drop-in SwiftUI view.** Embed `TourSlideshowView` inside any sheet, window, or custom layout you already manage.
- **Ready-to-use floating window on macOS.** `TourKitWindowController` presents a borderless, draggable, card-sized window — perfect for onboarding on app launch.
- **Polished dark UI.** Gradient blending between artwork and the text panel, animated page indicator, and subtle glass-style icon buttons (with liquid-glass material on newer OS versions).
- **Fully localizable text.** `title`, `description`, and button labels are `LocalizedStringKey`s, with optional per-page `tableName` and `stringsBundle` overrides for custom `.strings` / `.xcstrings` tables.
- **Flexible image loading.** Load images from your asset catalog, a specific module bundle (e.g. `.module`), or on-disk resource files (`png`, `jpg`, `heic`, `tiff`, `gif`, `webp`, …).
- **Smooth transitions.** Animated page changes and a keyboard shortcut (`Return`) on the primary action.
- **Zero dependencies.** Pure SwiftUI + AppKit.

### Coming Soon

- **iOS support.** Full feature parity with the macOS experience, including a UIKit-friendly presenter.
- **Richer slide content.** Go beyond a title and description — custom SwiftUI views, videos, and interactive elements per slide.

## Package Platform Support

- macOS 13+

## Installation

Add TourKit as a Swift Package dependency in Xcode, or in your `Package.swift`:

```swift
.package(url: "https://github.com/rampatra/TourKit.git", from: "1.0.0")
```

Then add `"TourKit"` to your target's dependencies.

## What You Configure

Each slide is a `TourPage` with:

- `imageName` — image in your app's asset catalog (or a resource in `imageBundle`)
- `imageBundle` — optional bundle to load the image from (defaults to the host app bundle)
- `title` — headline shown on the slide
- `description` — supporting copy shown under the title
- `tableName` / `stringsBundle` — optional localization overrides for `title` and `description`

## Usage

There are two ways to use TourKit:

1. **Embed `TourSlideshowView` directly** inside any SwiftUI view, sheet, or window you already manage.
2. **Present a standalone floating window** on macOS using `TourKitWindowController`.

### 1. Initialize `TourSlideshowView` (SwiftUI)

Use this when you want the tour to live inside your own layout, sheet, or window.

```swift
import SwiftUI
import TourKit

struct WelcomeTourView: View {
    var body: some View {
        TourSlideshowView(
            pages: [
                TourPage(
                    imageName: "tour-welcome",
                    title: "Welcome to MyApp",
                    description: "Get started quickly with a clean new interface."
                ),
                TourPage(
                    imageName: "tour-search",
                    title: "All New Spotlight Search",
                    description: "Find what you need instantly with intuitive search."
                ),
                TourPage(
                    imageName: "tour-automation",
                    title: "Smarter Automation",
                    description: "Save time by automating repetitive actions."
                )
            ],
            continueButtonTitle: "Continue",
            finishButtonTitle: "Get Started",
            onFinish: {
                // Called when the user taps the finish button on the last slide.
            },
            onClose: {
                // Called when the user taps the checkmark to dismiss the tour.
            }
        )
        .frame(width: 660)
        .padding()
    }
}
```

### 2. Present the Tour Window (macOS)

On macOS you can present the tour as a borderless, draggable, floating window — ideal for onboarding on app launch. Keep a reference to the controller so the window isn't deallocated while it's on screen.

```swift
import SwiftUI
import AppKit
import TourKit

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let tour = TourKitWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)

        tour.present(
            pages: [
                TourPage(
                    imageName: "tour-welcome",
                    title: "Welcome to MyApp",
                    description: "Get started quickly with a clean new interface."
                ),
                TourPage(
                    imageName: "tour-search",
                    title: "All New Spotlight Search",
                    description: "Find what you need instantly with intuitive search."
                )
            ],
            width: 660,
            continueButtonTitle: "Continue",
            finishButtonTitle: "Get Started",
            onFinish: {
                // Called on the last slide's finish button.
            },
            onClose: {
                // Called when the user closes the window (checkmark or finish).
            }
        )
    }
}
```

You can also dismiss the window programmatically:

```swift
tour.close()
```

Calling `present(...)` again while a window is already visible will simply bring it to the front.

> **Note:** For best results, use images with a **16:10 aspect ratio**. The slide layout blends the top of the image into the dark bottom panel, so 16:10 assets keep headlines and subtitles from feeling cramped and avoid awkward letterboxing.

## Sample App

The package includes a runnable macOS sample target named `TourKitSampleApp` that demonstrates both usage styles with bundled screenshots.

### Run in Xcode

1. Open this package in Xcode.
2. Select the `TourKitSampleApp` scheme.
3. Run (`Cmd + R`).

### Run from Terminal

```bash
swift run TourKitSampleApp
```

## Notes

- `imageBundle` in `TourPage` is optional. By default it is `nil`, so images are loaded from the host app bundle. If you ship images inside another bundle (e.g. a package module), pass that bundle explicitly using `imageBundle: .module`.
- Localized strings for `title` and `description` are looked up using `tableName` and `stringsBundle` when provided; otherwise the default `Localizable` table and `imageBundle` are used.
- For best results, use images with a **16:10 aspect ratio**.

## Wall of Fame

Apps using TourKit. Click an icon to visit the app.

<p>
  <a href="https://presentifyapp.com/"><img src="Documentation/Images/WOF/presentify.png" alt="Presentify" width="64" height="64" /></a>
  &nbsp;
  <a href="https://facescreenapp.com/"><img src="Documentation/Images/WOF/facescreen.png" alt="FaceScreen" width="64" height="64" /></a>
  &nbsp;
  <a href="https://keyscreenapp.com/"><img src="Documentation/Images/WOF/keyscreen.png" alt="KeyScreen" width="64" height="64" /></a>
  &nbsp;
  <a href="https://todobarapp.com/"><img src="Documentation/Images/WOF/todobar.png" alt="ToDoBar" width="64" height="64" /></a>
</p>

### Add Your App

Shipping an app that uses TourKit? We'd love to feature it. Open a pull request with:

1. **Icon file.** Add your app icon to `Documentation/Images/WOF/` following the existing format:
   - File name: lowercase app name, e.g. `myapp.png`.
   - Format: `.png` with a transparent background.
   - Recommended source size: **512×512** (or any square size ≥ 128×128).
2. **README entry.** Add a new `<a><img></a>` pair to the Wall of Fame list above, matching the existing entries. Link the icon to your app's website or App Store page.
3. **PR description.** Briefly describe your app, how it uses TourKit, and attach a screenshot of TourKit running inside it.

## License

TourKit is released under the [MIT License](LICENSE). You are free to use it in personal and commercial projects, provided that the copyright notice and permission notice are preserved. The software is provided "as is", without warranty of any kind.