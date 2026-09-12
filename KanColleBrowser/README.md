# KanColle Browser

Initial iOS/WebKit prototype for an in-app KanColle browser.

## Current prototype

- SwiftUI shell
- `WKWebView`
- Persistent/default WebKit website data store
- DMM `ckcy=1` region-cookie baseline
- Cookie installation before the first navigation
- JavaScript -> Swift game-size bridge
- `ResizeObserver`-based game-size detection
- Dynamic scale calculation
- Landscape orientation on iPhone
- Placeholder game selector (`#game`)

## Important next steps

1. Verify the current KC3Kai implementation of the DMM region cookie against the
   exact public-repository source before release.
2. Inspect the current KanColle DOM and replace `#game` with the real game
   container/canvas selector.
3. Implement the actual scaling of that game element. The current prototype
   only calculates and exposes the scale; it intentionally does not yet
   transform the page.
4. Map touch coordinates correctly after scaling.
5. Add DMM/KanColle navigation and error handling.
6. Test login persistence and cookie behavior on physical iOS devices.

## Building

Open `KanColleBrowser.xcodeproj` in Xcode 16 or newer, select an iOS simulator
or device, and run.

The bundle identifier is `com.example.KanColleBrowser`; change it to your own
unique identifier for device distribution.

## Licensing

This prototype does not include copied KC3Kai source code. It implements the
architecture discussed in this project using Apple's WebKit APIs. If code is
later ported directly from KC3Kai, retain the applicable upstream license and
copyright notices.
