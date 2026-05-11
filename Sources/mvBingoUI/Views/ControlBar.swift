import SwiftUI
import mvBingoKit

/// Bottom action row: draw the next ball (or show a countdown when the
/// auto-advance timer is on), start a fresh card, restart with the same
/// card.
public struct ControlBar: View {

    @Bindable public var session: BingoSession
    public let ballInterval: BallInterval
    public let nextDrawAt: Date?
    public let isPaused: Bool
    public let onTogglePause: () -> Void
    @Environment(\.bingoTheme) private var theme

    public init(
        session: BingoSession,
        ballInterval: BallInterval = .manual,
        nextDrawAt: Date? = nil,
        isPaused: Bool = false,
        onTogglePause: @escaping () -> Void = {}
    ) {
        self.session = session
        self.ballInterval = ballInterval
        self.nextDrawAt = nextDrawAt
        self.isPaused = isPaused
        self.onTogglePause = onTogglePause
    }

    public var body: some View {
        HStack(spacing: 14) {
            controlButton(
                systemImage: "arrow.uturn.backward",
                label: "Restart",
                isEnabled: true
            ) {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                    session.restart()
                }
            }

            middleSlot

            controlButton(
                systemImage: "shuffle",
                label: "New Card",
                isEnabled: true
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                    session.newCards()
                }
            }
        }
    }

    /// Manual mode → Next Ball button. Auto mode → live countdown card.
    @ViewBuilder
    private var middleSlot: some View {
        if ballInterval.isManual {
            primaryButton(
                systemImage: "arrow.forward.circle.fill",
                label: "Next Ball",
                isEnabled: !session.isExhausted && !session.hasBingo
            ) {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                    _ = session.drawNext()
                }
            }
        } else {
            CountdownCard(
                nextDrawAt: nextDrawAt,
                intervalSeconds: ballInterval.seconds ?? 0,
                isPaused: isPaused,
                isGameOver: session.hasBingo || session.isExhausted,
                onTogglePause: onTogglePause
            )
        }
    }

    private func primaryButton(
        systemImage: String,
        label: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.bold))
                Text(label)
                    .font(.callout.weight(.bold))
                    .textCase(.uppercase)
                    .tracking(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isEnabled ? theme.lastBallText : theme.bodyColor.opacity(0.4))
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isEnabled ? theme.lastBallRing : theme.bodyColor.opacity(0.15))
        )
        .disabled(!isEnabled)
    }

    private func controlButton(
        systemImage: String,
        label: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
                    .tracking(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isEnabled ? theme.headlineColor : theme.bodyColor.opacity(0.4))
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(theme.bodyColor.opacity(0.18), lineWidth: 1)
                )
        )
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
    }
}

/// Live countdown to the next auto-drawn ball. Tap to pause / resume.
///
/// Compact vertical layout that matches the side buttons' icon + label
/// shape: a circular progress ring with the seconds digit inside (or a
/// pause/check icon when frozen), and a single uppercase caption below.
private struct CountdownCard: View {

    let nextDrawAt: Date?
    let intervalSeconds: TimeInterval
    let isPaused: Bool
    let isGameOver: Bool
    let onTogglePause: () -> Void
    @Environment(\.bingoTheme) private var theme

    private var isFrozen: Bool { isPaused || isGameOver }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: isFrozen)) { ctx in
            let remaining: TimeInterval = {
                guard let target = nextDrawAt, !isFrozen else { return 0 }
                return max(0, target.timeIntervalSince(ctx.date))
            }()
            let progress: Double = intervalSeconds > 0
                ? max(0, min(1, remaining / intervalSeconds))
                : 0
            let secondsLabel = nextDrawAt == nil ? "—" : "\(Int(ceil(remaining)))"

            Button(action: onTogglePause) {
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(theme.lastBallText.opacity(0.28), lineWidth: 2.5)
                        if !isFrozen {
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(theme.lastBallText, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        }
                        if isGameOver {
                            Image(systemName: "checkmark")
                                .font(.subheadline.weight(.heavy))
                                .foregroundStyle(theme.lastBallText)
                        } else if isPaused {
                            Image(systemName: "play.fill")
                                .font(.subheadline.weight(.heavy))
                                .foregroundStyle(theme.lastBallText)
                        } else {
                            Text(secondsLabel)
                                .font(.callout.weight(.heavy))
                                .foregroundStyle(theme.lastBallText)
                                .monospacedDigit()
                        }
                    }
                    .frame(width: 28, height: 28)

                    Text(footerLabel)
                        .font(.caption2.weight(.semibold))
                        .textCase(.uppercase)
                        .tracking(0.6)
                        .foregroundStyle(theme.lastBallText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(theme.lastBallRing.opacity(isFrozen ? 0.55 : 1.0))
                )
            }
            .buttonStyle(.plain)
            .disabled(isGameOver)
            .accessibilityLabel(accessibilityLabelText)
        }
    }

    private var footerLabel: String {
        if isGameOver { return "Done" }
        if isPaused { return "Paused" }
        return "Auto"
    }

    private var accessibilityLabelText: String {
        if isGameOver { return "Game over" }
        if isPaused { return "Resume auto-advance" }
        return "Pause auto-advance"
    }
}
