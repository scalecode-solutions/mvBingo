import SwiftUI
import mvBingoKit

/// Modal sheet with the player's session preferences. Each control writes
/// directly to `@AppStorage` so changes persist across launches.
///
/// Some toggles are dormant until later feature branches wire them up
/// (sound effects, auto-daub behavior, auto-advance timer). The keys
/// already exist so adding the behavior later is a single read each.
public struct SettingsSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.bingoTheme) private var theme

    @AppStorage(BingoSettingsKey.cardCount)
    private var cardCount: Int = BingoSettingsDefault.cardCount

    @AppStorage(BingoSettingsKey.autoDaub)
    private var autoDaub: Bool = BingoSettingsDefault.autoDaub

    @AppStorage(BingoSettingsKey.ballIntervalRawValue)
    private var ballIntervalRaw: Int = BingoSettingsDefault.ballIntervalRawValue

    @AppStorage(BingoSettingsKey.soundMuted)
    private var soundMuted: Bool = BingoSettingsDefault.soundMuted

    @AppStorage(BingoSettingsKey.themeName)
    private var themeNameRaw: String = BingoSettingsDefault.themeName

    public init() {}

    private var ballInterval: Binding<BallInterval> {
        Binding(
            get: { BallInterval(rawValue: ballIntervalRaw) ?? .manual },
            set: { ballIntervalRaw = $0.rawValue }
        )
    }

    public var body: some View {
        NavigationStack {
            Form {
                cardsSection
                daubingSection
                timerSection
                soundSection
                themeSection
            }
            .scrollContentBackground(.hidden)
            .background(theme.pageBackground.ignoresSafeArea())
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(theme.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(theme.headlineColor)
                }
            }
            #endif
        }
    }

    private var cardsSection: some View {
        Section {
            Picker("Cards", selection: $cardCount) {
                ForEach(1...BingoSession.maxCards, id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            sectionHeader("Cards")
        } footer: {
            Text("Play 1 to \(BingoSession.maxCards) cards at once. More cards = more chances to bingo on each draw.")
                .foregroundStyle(theme.bodyColor.opacity(0.8))
        }
    }

    private var daubingSection: some View {
        Section {
            Toggle("Auto Daub", isOn: $autoDaub)
                .tint(theme.lastBallRing)
        } header: {
            sectionHeader("Daubing")
        } footer: {
            Text(autoDaub
                 ? "Cells daub themselves as soon as their number is called."
                 : "Tap a cell to daub it manually after the number is called.")
                .foregroundStyle(theme.bodyColor.opacity(0.8))
        }
    }

    private var timerSection: some View {
        Section {
            Picker("Time between balls", selection: ballInterval) {
                ForEach(BallInterval.allCases) { interval in
                    Text(interval.label).tag(interval)
                }
            }
        } header: {
            sectionHeader("Timer")
        } footer: {
            Text("Choose a fixed delay between calls, or Manual to advance by tapping Next Ball.")
                .foregroundStyle(theme.bodyColor.opacity(0.8))
        }
    }

    private var soundSection: some View {
        Section {
            Toggle("Mute", isOn: $soundMuted)
                .tint(theme.lastBallRing)
        } header: {
            sectionHeader("Sound")
        } footer: {
            Text("Sound effects play on draws, daubs, and BINGO when unmuted.")
                .foregroundStyle(theme.bodyColor.opacity(0.8))
        }
    }

    private var themeSection: some View {
        Section {
            Picker("Theme", selection: $themeNameRaw) {
                ForEach(BingoThemeName.allCases) { name in
                    Text(name.label).tag(name.rawValue)
                }
            }
        } header: {
            sectionHeader("Theme")
        } footer: {
            Text("Picks the color palette used across the whole game.")
                .foregroundStyle(theme.bodyColor.opacity(0.8))
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.6)
            .foregroundStyle(theme.bodyColor)
    }
}
