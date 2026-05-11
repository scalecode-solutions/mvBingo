import SwiftUI
import mvBingoKit

/// Top-level bingo scene. Drop into a SwiftUI hierarchy and you're playing.
///
/// ```swift
/// BingoSessionView()
///     .bingoTheme(.churchBasement)
/// ```
public struct BingoSessionView: View {

    @State private var session: BingoSession
    @State private var isShowingSettings = false
    @Environment(\.bingoTheme) private var theme

    @AppStorage(BingoSettingsKey.cardCount)
    private var cardCount: Int = BingoSettingsDefault.cardCount

    @AppStorage(BingoSettingsKey.autoDaub)
    private var autoDaub: Bool = BingoSettingsDefault.autoDaub

    @AppStorage(BingoSettingsKey.ballIntervalRawValue)
    private var ballIntervalRaw: Int = BingoSettingsDefault.ballIntervalRawValue

    @AppStorage(BingoSettingsKey.soundMuted)
    private var soundMuted: Bool = BingoSettingsDefault.soundMuted

    @State private var soundPlayer = SoundEffectPlayer()

    private var ballInterval: BallInterval {
        BallInterval(rawValue: ballIntervalRaw) ?? .manual
    }

    private var totalMarkCount: Int {
        session.marks.reduce(0) { $0 + $1.count }
    }

    /// Combined id for the auto-advance task. Changing the interval OR
    /// restarting the session (which updates `startedAt`) restarts the loop.
    private struct AutoAdvanceID: Hashable {
        let interval: Int
        let sessionStart: Date
    }

    public init(session: BingoSession? = nil) {
        // Read the persisted card count so the session boots with the
        // player's last setting; defaults to 1 on first launch.
        let stored = UserDefaults.standard.object(forKey: BingoSettingsKey.cardCount) as? Int
        let count = stored ?? BingoSettingsDefault.cardCount
        let clamped = max(1, min(BingoSession.maxCards, count))
        let initial = session ?? BingoSession.random(cardCount: clamped)
        _session = State(initialValue: initial)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            theme.pageBackground.ignoresSafeArea()

            VStack(spacing: 14) {
                header

                HStack(alignment: .center, spacing: 16) {
                    LastBallView(ball: session.lastDrawn)
                    statusBlock
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)

                cardsLayout
                    .padding(.horizontal, 14)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)

                CallHistoryView(drawn: session.drawn)
                    .padding(.horizontal)

                Spacer(minLength: 0)

                ControlBar(session: session)
                    .padding(.horizontal)
                    .safeAreaPadding(.bottom, 8)
            }
            .padding(.top, 8)
        }
        .onChange(of: cardCount) { _, new in
            let clamped = max(1, min(BingoSession.maxCards, new))
            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                session.setCardCount(clamped)
            }
        }
        // Auto-daub + ball-drawn sound: both fire on each new draw.
        .onChange(of: session.drawn.count) { old, new in
            guard new > old else { return }
            if !soundMuted { soundPlayer.play(.ballDrawn) }
            guard autoDaub else { return }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                session.autoMarkCalledNumbers()
            }
        }
        // Daub sound on any new mark, regardless of source (user tap or
        // auto-daub). Tracked via the total mark count across all cards.
        .onChange(of: totalMarkCount) { old, new in
            if new > old, !soundMuted {
                soundPlayer.play(.daub)
            }
        }
        // BINGO fanfare when the first card completes the pattern.
        .onChange(of: session.firstWin?.cardIndex) { old, new in
            if new != nil, old == nil, !soundMuted {
                soundPlayer.play(.bingo)
            }
        }
        .onChange(of: autoDaub) { _, new in
            guard new else { return }
            withAnimation(.spring(response: 0.32, dampingFraction: 0.75)) {
                session.autoMarkCalledNumbers()
            }
        }
        // Auto-advance: when ballInterval is non-manual, draw a ball every N
        // seconds. Re-keyed on session.startedAt so restarting the game also
        // restarts the loop.
        .task(id: AutoAdvanceID(interval: ballIntervalRaw, sessionStart: session.startedAt)) {
            guard let seconds = ballInterval.seconds else { return }
            while !Task.isCancelled,
                  !session.hasBingo,
                  !session.isExhausted {
                do {
                    try await Task.sleep(for: .seconds(seconds))
                } catch {
                    return
                }
                if Task.isCancelled { return }
                guard !session.hasBingo, !session.isExhausted else { return }
                withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                    _ = session.drawNext()
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsSheet()
                .bingoTheme(theme)
                .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("Bingo")
                .font(.system(.largeTitle, design: .serif).weight(.bold))
                .foregroundStyle(theme.headlineColor)
            Spacer()
            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(theme.headlineColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle().stroke(theme.bodyColor.opacity(0.22), lineWidth: 1)
                            )
                    )
            }
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal)
    }

    private var statusBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.pattern.label)
                .font(.headline.weight(.bold))
                .foregroundStyle(theme.headlineColor)
            Text("\(session.drawn.count) of 75 called")
                .font(.subheadline)
                .foregroundStyle(theme.bodyColor.opacity(0.9))
                .monospacedDigit()
            if let win = session.firstWin {
                Text(session.cardCount > 1
                     ? "BINGO — Card \(win.cardIndex + 1)!"
                     : "BINGO — \(win.pattern.label)!")
                    .font(.callout.weight(.bold))
                    .foregroundStyle(theme.lastBallRing)
                    .padding(.top, 2)
            }
        }
    }

    /// Lays out 1...4 cards adaptively. Single card is full-width; 2 and 3
    /// stack vertically; 4 fits in a 2×2 grid.
    @ViewBuilder
    private var cardsLayout: some View {
        switch session.cardCount {
        case 1:
            BingoCardView(session: session, cardIndex: 0)
        case 4:
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    BingoCardView(session: session, cardIndex: 0)
                    BingoCardView(session: session, cardIndex: 1)
                }
                HStack(spacing: 8) {
                    BingoCardView(session: session, cardIndex: 2)
                    BingoCardView(session: session, cardIndex: 3)
                }
            }
        default:
            VStack(spacing: 8) {
                ForEach(0..<session.cardCount, id: \.self) { i in
                    BingoCardView(session: session, cardIndex: i)
                }
            }
        }
    }
}
