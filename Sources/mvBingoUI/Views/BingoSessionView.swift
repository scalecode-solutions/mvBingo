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

            VStack(spacing: 14) {
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
                        if let win = session.firstWin {
                            Text(session.cardCount > 1
                                 ? "BINGO — Card \(win.cardIndex + 1)!"
                                 : "BINGO — \(win.pattern.label)!")
                                .font(.callout.weight(.bold))
                                .foregroundStyle(theme.lastBallRing)
                                .padding(.top, 2)
                        }
                    }
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
