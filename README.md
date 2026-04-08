# TourKit

TourKit is a Swift Package that provides a SwiftUI slideshow view for feature walkthroughs and onboarding flows.

## What You Configure

Each slide uses:

- `imageName` (from your app's asset catalog)
- `title`
- `description`

## Usage

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
            finishButtonTitle: "Get Started"
        ) {
            // Called on the last slide button tap.
        }
        .padding()
    }
}
```

## Package Platform Support

- macOS 13+
- iOS 16+

## Notes

- `imageBundle` in `TourPage` is optional. By default it is `nil`, so images are loaded from the host app bundle.
- If you ship images inside another bundle, pass that bundle explicitly using `imageBundle`.
