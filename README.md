# mvBingo

A Swift Package for standard 75-ball bingo. Built for iOS 26 with SwiftUI 6.
Two products: a pure-Swift engine (`mvBingoKit`) and a SwiftUI view layer
(`mvBingoUI`).

> Drop `BingoSessionView()` into any SwiftUI app and you've got bingo —
> card, big call display, call history, and the controls to play. Themeable.

## Requirements

- iOS 26 (iPhone)
- Xcode 26 / Swift 6.2+

(Also builds on macOS 26 so `swift test` works locally; the UI is designed
for iPhone.)

## Install

```swift
dependencies: [
    .package(url: "https://github.com/scalecode-solutions/mvBingo.git", from: "0.3.5"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "mvBingoUI", package: "mvBingo"),
            // engine-only:
            // .product(name: "mvBingoKit", package: "mvBingo"),
        ]
    )
]
```

## Quick start

```swift
import SwiftUI
import mvBingoUI

struct ContentView: View {
    var body: some View {
        BingoSessionView()
            .bingoTheme(.churchBasement)
    }
}
```

That's it. The view owns a `BingoSession`, draws balls on tap, lets the
player dab matches, and detects the winning pattern.

## Features

- **75-ball standard format** — B 1-15, I 16-30, N 31-45, G 46-60, O 61-75
- **5 winning patterns** — Any Line, Four Corners, X, Plus, Blackout —
  switchable in Settings
- **1 to 4 cards on screen** — solo or simulate a multi-card bingo hall
- **Free center space** — pre-marked and can't be toggled off
- **Manual or auto-daub** — tap to mark, or let the app catch matches
- **Manual or auto-advance** — tap Next Ball, or pick a 5/10/15/20 second
  draw timer with a live countdown card you can tap to pause / resume
- **Background-aware** — backgrounding auto-pauses the timer and silences
  any mid-sentence voice announcement; foregrounding resumes
- **Voice caller (optional)** — `AVSpeechSynthesizer` announces each ball:
  "B... twelve"
- **Procedural sound effects (optional)** — ball-pop, daub-tap, BINGO
  fanfare, no audio assets shipped
- **Four themes** — Church Basement, Vegas Night, Cracker Barrel, Kid
  Friendly. Settings picker, persists across launches
- **Pluggable persistence** — `StatsStore` protocol with `UserDefaults`
  (zero-dep) and `SwiftData` (queryable) backends shipped
- **Settings sheet + stats sheet** — gear and chart icons in the header
- **Engine-only embeddable** — `import mvBingoKit` if you want to drive
  bingo with your own UI

## Architecture

```
mvBingoKit  (pure Swift, zero UI deps)
├── Model        BingoBall · BingoCard · GridPoint · WinPattern
├── Game         BingoSession (@Observable, 1-4 cards) · BingoStatus
└── Persistence  StatsStore protocol
                 ├── UserDefaultsStatsStore
                 └── SwiftDataStatsStore (@ModelActor + @Model)

mvBingoUI   (SwiftUI 6)
├── Theme        Theme value type + 4 named themes + BingoThemeName
├── Settings     @AppStorage keys + defaults + BallInterval
├── Audio        SoundEffectPlayer · BingoCaller (AVSpeechSynthesizer)
└── Views        BingoSessionView (top-level) + BingoCardView · LastBallView
                 · CallHistoryView · ControlBar · SettingsSheet · StatsSheet
```

## Theming

```swift
BingoSessionView()
    .bingoTheme(.churchBasement)
```

`Theme` is a value type with public initializers — build your own palette
and pass it via `.bingoTheme(myTheme)` at any level above
`BingoSessionView`.

## Demo

`Demo/mvBingoDemo.xcodeproj` is a single-target iPhone app wired to the
local SPM via a relative-path reference. Open it, build, run.

## Testing

`swift test` from the package root. The kit's 29 Swift Testing cases cover
ball construction, card random validity, win-pattern set sizes, draw
mechanics, mark/unmark, free-space invariants, and bingo detection for line
and diagonal patterns.

## Development setup

mvBingoUI pulls in
[`scalecode-metal-plugin`](https://github.com/scalecode-solutions/scalecode-metal-plugin),
which ships an SPM build-tool plugin. Xcode prompts you to **Trust & Enable
Plugin** on first open of any project that depends on it. To skip these
prompts for your user account on this machine:

```sh
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
```

Restart Xcode. To revert, `defaults delete` the same keys.

## License

[MIT](LICENSE). Use it freely.
