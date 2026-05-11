import Foundation

/// The pattern that constitutes a winning bingo. Each case knows the
/// set(s) of grid points that, if all marked, count as a win.
public enum WinPattern: String, Hashable, Sendable, Codable, CaseIterable {
    case anyLine        // any row, column, or main diagonal
    case fourCorners
    case x              // both diagonals
    case plus           // middle row + middle column
    case blackout       // every cell

    public var label: String {
        switch self {
        case .anyLine:     "Any Line"
        case .fourCorners: "Four Corners"
        case .x:           "X"
        case .plus:        "Plus"
        case .blackout:    "Blackout"
        }
    }

    public var blurb: String {
        switch self {
        case .anyLine:     "Mark a complete row, column, or diagonal."
        case .fourCorners: "Mark all four corners."
        case .x:           "Mark both diagonals."
        case .plus:        "Mark the middle row and middle column."
        case .blackout:    "Mark every cell on the card."
        }
    }

    /// Sets of grid points that each count as a win. Mark *all* of *any one*
    /// set to BINGO.
    public var winningSets: [Set<GridPoint>] {
        switch self {
        case .anyLine:
            var sets: [Set<GridPoint>] = []
            for row in 0..<5 {
                sets.append(Set((0..<5).map { GridPoint(column: $0, row: row) }))
            }
            for col in 0..<5 {
                sets.append(Set((0..<5).map { GridPoint(column: col, row: $0) }))
            }
            sets.append(Set((0..<5).map { GridPoint(column: $0, row: $0) }))
            sets.append(Set((0..<5).map { GridPoint(column: $0, row: 4 - $0) }))
            return sets

        case .fourCorners:
            return [Set([
                GridPoint(column: 0, row: 0),
                GridPoint(column: 4, row: 0),
                GridPoint(column: 0, row: 4),
                GridPoint(column: 4, row: 4),
            ])]

        case .x:
            var set: Set<GridPoint> = []
            for i in 0..<5 {
                set.insert(GridPoint(column: i, row: i))
                set.insert(GridPoint(column: i, row: 4 - i))
            }
            return [set]

        case .plus:
            var set: Set<GridPoint> = []
            for i in 0..<5 {
                set.insert(GridPoint(column: 2, row: i))
                set.insert(GridPoint(column: i, row: 2))
            }
            return [set]

        case .blackout:
            return [Set(BingoCard.allPoints)]
        }
    }
}
