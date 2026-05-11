import SwiftUI
import mvBingoKit

/// A compact grid of all 75 possible numbers, broken into B-I-N-G-O columns.
/// Drawn numbers are highlighted; everything else dims. Lets the player (or
/// the host on a TV) glance at "what's been called so far."
public struct CallHistoryView: View {

    public let drawn: [BingoBall]
    @Environment(\.bingoTheme) private var theme

    public init(drawn: [BingoBall]) {
        self.drawn = drawn
    }

    public var body: some View {
        let drawnSet = Set(drawn.map(\.number))
        VStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { columnIndex in
                HStack(spacing: 4) {
                    Text(["B", "I", "N", "G", "O"][columnIndex])
                        .font(.system(.caption, design: .rounded).weight(.heavy))
                        .foregroundStyle(theme.headerText)
                        .frame(width: 22, height: 22)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.headerBackground)
                        )

                    ForEach(BingoBall.letterRanges[columnIndex], id: \.self) { number in
                        let isDrawn = drawnSet.contains(number)
                        Text("\(number)")
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .foregroundStyle(isDrawn ? theme.cellText : theme.bodyColor.opacity(0.45))
                            .frame(maxWidth: .infinity, minHeight: 22)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(isDrawn ? theme.dauberInk.opacity(0.85) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .stroke(theme.bodyColor.opacity(0.18), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.cardBackground.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(theme.bodyColor.opacity(0.18), lineWidth: 1)
                )
        )
    }
}
