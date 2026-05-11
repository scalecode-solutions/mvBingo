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
    @Environment(\.bingoTheme) private var theme

    public init(session: BingoSession? = nil) {
        let initial = session ?? BingoSession.random()
        _session = State(initialValue: initial)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            theme.pageBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                HStack(alignment: .center, spacing: 16) {
                    LastBallView(ball: session.lastDrawn)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.pattern.label)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(theme.headlineColor)
                        Text("\(session.drawn.count) of 75 called")
                            .font(.subheadline)
                            .foregroundStyle(theme.bodyColor.opacity(0.9))
                            .monospacedDigit()
                        if case .bingo(let pattern, _) = session.status {
                            Text("BINGO — \(pattern.label)!")
                                .font(.callout.weight(.bold))
                                .foregroundStyle(theme.lastBallRing)
                                .padding(.top, 2)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)

                BingoCardView(session: session)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: 540)
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
    }

    private var header: some View {
        HStack {
            Text("Bingo")
                .font(.system(.largeTitle, design: .serif).weight(.bold))
                .foregroundStyle(theme.headlineColor)
            Spacer()
        }
        .padding(.horizontal)
    }
}
