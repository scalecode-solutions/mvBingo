import SwiftUI
import mvBingoKit

/// The hero readout of the most-recently-drawn ball. Big circular badge with
/// the letter and number; goes empty when no draws yet.
public struct LastBallView: View {

    public let ball: BingoBall?
    @Environment(\.bingoTheme) private var theme

    public init(ball: BingoBall?) {
        self.ball = ball
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(theme.lastBallRing, lineWidth: 4)
                .background(
                    Circle()
                        .fill(theme.lastBallRing.opacity(0.16))
                )

            if let ball {
                VStack(spacing: 0) {
                    Text(ball.letter)
                        .font(.system(.title, design: .rounded).weight(.black))
                        .foregroundStyle(theme.lastBallText)
                    Text("\(ball.number)")
                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                        .foregroundStyle(theme.lastBallText)
                        .monospacedDigit()
                }
                .transition(.scale.combined(with: .opacity))
                .id(ball) // re-runs the transition on each new ball
            } else {
                Text("—")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(theme.lastBallText.opacity(0.5))
            }
        }
        .frame(width: 110, height: 110)
        .animation(.spring(response: 0.34, dampingFraction: 0.72), value: ball)
    }
}
