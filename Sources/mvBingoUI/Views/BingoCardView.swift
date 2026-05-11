import SwiftUI
import mvBingoKit

/// Renders a bingo card: B-I-N-G-O header row + 5×5 grid of cells. Tap a
/// cell to toggle its dauber mark (no-op for cells whose number hasn't
/// been called).
public struct BingoCardView: View {

    @Bindable public var session: BingoSession
    @Environment(\.bingoTheme) private var theme

    public init(session: BingoSession) {
        self.session = session
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

    private var headerRow: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { col in
                Text(["B", "I", "N", "G", "O"][col])
                    .font(.system(.title, design: .rounded).weight(.black))
                    .foregroundStyle(theme.headerText)
                    .frame(maxWidth: .infinity, minHeight: 44)
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
        let isMarked = session.marks.contains(point)
        let isCallable = session.isCallable(point)
        let isWinningCell: Bool = {
            if case .bingo(_, let winningCells) = session.status {
                return winningCells.contains(point)
            }
            return false
        }()

        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isCallable ? theme.calledHighlight : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.cellText.opacity(0.18), lineWidth: 1)
                )

            if isFree {
                Text("FREE")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundStyle(theme.cellText.opacity(0.5))
            } else if let n = session.card.number(at: point) {
                Text("\(n)")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(theme.cellText)
                    .monospacedDigit()
            }

            if isMarked {
                // Dauber ink blot — sized just under the cell.
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
                session.toggleMark(at: point)
            }
        }
    }
}
