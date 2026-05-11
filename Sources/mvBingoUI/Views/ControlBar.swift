import SwiftUI
import mvBingoKit

/// Bottom action row: draw the next ball, start a fresh card, restart with
/// the same card.
public struct ControlBar: View {

    @Bindable public var session: BingoSession
    @Environment(\.bingoTheme) private var theme

    public init(session: BingoSession) {
        self.session = session
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

            primaryButton(
                systemImage: "arrow.forward.circle.fill",
                label: "Next Ball",
                isEnabled: !session.isExhausted && !session.hasBingo
            ) {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                    _ = session.drawNext()
                }
            }

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
