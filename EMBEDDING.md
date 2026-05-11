# Embedding BingoSessionView in a Host App

`BingoSessionView` ships in two modes. The default (`embedded: false`) owns
the whole screen and draws its own title row with the Stats and Settings
buttons — that's what `Demo/mvBingoDemo` uses. The other mode is for
slotting the game *inside* an existing app shell (NavigationStack, TabView,
sheet, anywhere with its own chrome).

## Standalone

```swift
import mvBingoUI

struct ContentView: View {
    var body: some View {
        BingoSessionView()
            .bingoTheme(.churchBasement)
    }
}
```

That's it — runs as today with the internal header (title + stats button +
settings button).

## Embedded

Three opt-in parameters:

```swift
public init(
    session: BingoSession? = nil,
    statsStore: any StatsStore = UserDefaultsStatsStore(),
    embedded: Bool = false,
    isShowingStats: Binding<Bool>? = nil,
    isShowingSettings: Binding<Bool>? = nil
)
```

- **`embedded: true`** hides the internal title row. The host's nav bar
  is the only top chrome on screen; the wood-grain page background still
  extends edge-to-edge underneath it.
- **`isShowingStats`** is an optional external binding for the stats
  sheet.
- **`isShowingSettings`** is an optional external binding for the settings
  sheet.

When you hide the internal header you also lose its two trigger buttons,
so pass the bindings in and wire your own toolbar items to them — the
existing sheets pop up the same way.

```swift
import mvBingoUI

struct BingoDestination: View {
    @State private var showsStats = false
    @State private var showsSettings = false

    var body: some View {
        BingoSessionView(
            embedded: true,
            isShowingStats: $showsStats,
            isShowingSettings: $showsSettings
        )
        .bingoTheme(.churchBasement)
        .navigationTitle("Bingo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showsSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showsStats = true } label: {
                    Image(systemName: "chart.bar.fill")
                }
            }
        }
    }
}
```

Push that from any `NavigationStack` and you get:

- Host's system back chevron + nav-bar title
- Host's trailing toolbar buttons driving the same Stats and Settings
  sheets
- Bingo card + last-call readout + call-history grid + control bar wearing
  the chosen theme
- No double header, no chrome conflicts

The `ControlBar` already uses `.safeAreaPadding(.bottom, 8)`, so it
floats above whatever bottom inset is in effect — home indicator with
the tab bar hidden, the tab bar itself when the host keeps it visible,
nothing on macOS.

## What to keep

- **The theme.** `.bingoTheme(.churchBasement)` (or any of the bundled
  themes — `.vegasNight`, `.crackerBarrel`, `.kidFriendly`) is the
  visual identity. The user's pick from Settings overrides whatever
  the host hands in via environment.
- **The page background extending edge-to-edge.** Lets the host's nav bar
  sit on top of the bingo backdrop, which reads as "the game is the
  entire surface below the chrome." Right effect.
- **All `@AppStorage` settings.** The cards count, daub mode, ball
  timer, sound mute, voice toggle, theme name, and win pattern keys
  are all namespaced under `dev.scalecode.mvBingo.*`. They persist
  across launches and across embedded / standalone modes.
- **Background handling.** The view auto-pauses the auto-advance timer
  and cancels in-progress voice when the app enters
  `ScenePhase.background`. Foreground clears the auto-pause but
  respects any user-initiated pause. Don't add your own pause logic;
  the view already handles it.

## Picking a theme per host

The theme is read from the environment via `\.bingoTheme`. Apply it at
any level above `BingoSessionView`:

```swift
BingoSessionView(embedded: true, isShowingStats: $showsStats)
    .bingoTheme(.crackerBarrel)
```

Custom themes work too — `Theme` is a value type with a public
initializer, so you can build your own palette and substitute it. Or use
the bundled `BingoThemeName` enum to map a stable string to one of the
named themes.

Note: the user can override your choice from the Settings sheet's Theme
section. Once they pick, that takes precedence over the environment
value. If you want a locked theme without user override, hide the
settings binding and the user can't reach the picker.

## Persistence backends

Same `StatsStore` pattern as `PegGame`:

- **`UserDefaultsStatsStore`** — default, zero deps, JSON-blob in
  `UserDefaults`. Fine for modest history.
- **`SwiftDataStatsStore`** — `@ModelActor`-backed, queryable, scales.
  Construct once at app launch and pass via the `statsStore:` init
  parameter.

```swift
@main
struct YourApp: App {
    private let statsStore: any StatsStore

    init() {
        statsStore = (try? SwiftDataStatsStore()) ?? UserDefaultsStatsStore()
    }

    var body: some Scene {
        WindowGroup {
            BingoSessionView(statsStore: statsStore)
                .bingoTheme(.churchBasement)
        }
    }
}
```

## Compatibility

All three embed-mode parameters default to standalone behavior, so
existing call sites continue to work without modification:

```swift
BingoSessionView()                                       // unchanged
BingoSessionView(session: customSession)                 // unchanged
BingoSessionView(session: s, statsStore: customStore)    // unchanged
```
