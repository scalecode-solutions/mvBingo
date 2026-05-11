import SwiftUI
import mvBingoKit

/// Renders one bingo card: B-I-N-G-O header row + 5×5 grid of cells. Tap
/// a cell to toggle its dauber mark.
public struct BingoCardView: View {

    @Bindable public var session: BingoSession
    public let cardIndex: Int
    @Environment(\.bingoTheme) private var theme

    public init(session: BingoSession, cardIndex: Int = 0) {
        self.session = session
        self.cardIndex = cardIndex
    }

    public var body: some View {
        VStack(spacing: 4) {
            headerRow
            ForEach(0..<5, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { col in
                        cell(at: GridPoint(column: col, row: row))
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.cardBackground)
                .shadow(color: .black.opacity(0.4), radius: 14, x: 0, y: 8)
        )
    }

    private var card: BingoCard { session.cards[cardIndex] }

    private var headerRow: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { col in
                Text(["B", "I", "N", "G", "O"][col])
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(theme.headerText)
                    .frame(maxWidth: .infinity, minHeight: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.headerBackground)
                    )
            }
        }
    }

    @ViewBuilder
    private func cell(at point: GridPoint) -> some View {
        let isFree = point == BingoCard.freeSpace
        let isMarked = session.marks(card: cardIndex).contains(point)
        let isCallable = session.isCallable(card: cardIndex, point)
        let isWinningCell = session.isWinningCell(card: cardIndex, point)

        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isCallable ? theme.calledHighlight : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.cellText.opacity(0.18), lineWidth: 1)
                )

            if isFree {
                Text("FREE")
                    .font(.system(.caption2, design: .rounded).weight(.heavy))
                    .foregroundStyle(theme.cellText.opacity(0.5))
            } else if let n = card.number(at: point) {
                Text("\(n)")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(theme.cellText)
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
            }

            if isMarked {
                Circle()
                    .fill(theme.dauberInk)
                    .padding(4)
                    .transition(.scale.combined(with: .opacity))
            }

            if isWinningCell {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(theme.lastBallRing, lineWidth: 3)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                session.toggleMark(card: cardIndex, at: point)
            }
        }
    }
}
