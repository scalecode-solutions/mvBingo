import Foundation

/// A standard 5×5 bingo card.
///
/// Stored column-major: `cells[column][row]` is the number at that grid point,
/// or `nil` for the free space (always at column 2, row 2). Each column's
/// numbers come exclusively from that letter's range.
public struct BingoCard: Hashable, Sendable, Codable {

    /// Column-major 5×5: `cells[col][row]`.
    public let cells: [[Int?]]

    /// Position of the free space — always (col 2, row 2) by tradition.
    public static let freeSpace = GridPoint(column: 2, row: 2)

    /// Validate and store. Returns nil if the layout doesn't satisfy the
    /// standard B-I-N-G-O constraints (column ranges, free center, unique
    /// numbers).
    public init?(cells: [[Int?]]) {
        guard cells.count == 5, cells.allSatisfy({ $0.count == 5 }) else { return nil }

        for col in 0..<5 {
            let range = BingoBall.letterRanges[col]
            for row in 0..<5 {
                if col == Self.freeSpace.column && row == Self.freeSpace.row {
                    guard cells[col][row] == nil else { return nil }
                } else {
                    guard let n = cells[col][row], range.contains(n) else { return nil }
                }
            }
        }
        let numbers = cells.flatMap { $0 }.compactMap { $0 }
        guard Set(numbers).count == numbers.count else { return nil }

        self.cells = cells
    }

    /// Build a fresh random card. Each column draws 5 unique numbers from its
    /// letter range (only 4 in the N column to leave the center free).
    public static func random<R: RandomNumberGenerator>(using rng: inout R) -> BingoCard {
        var cells: [[Int?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
        for col in 0..<5 {
            let range = BingoBall.letterRanges[col]
            let isFreeCenter = (col == Self.freeSpace.column)
            let needed = isFreeCenter ? 4 : 5
            var picks = Array(range).shuffled(using: &rng).prefix(needed).map { Int($0) }

            for row in 0..<5 {
                if isFreeCenter && row == Self.freeSpace.row {
                    cells[col][row] = nil
                } else {
                    cells[col][row] = picks.removeFirst()
                }
            }
        }
        // Force-unwrap: by construction the result is valid.
        return BingoCard(cells: cells)!
    }

    public static func random() -> BingoCard {
        var rng = SystemRandomNumberGenerator()
        return random(using: &rng)
    }

    /// Number at the given grid point, or nil for the free space.
    public func number(at point: GridPoint) -> Int? {
        cells[point.column][point.row]
    }

    /// Where (if anywhere) the given ball lives on this card.
    public func position(of ball: BingoBall) -> GridPoint? {
        let col = ball.column
        for row in 0..<5 {
            if cells[col][row] == ball.number {
                return GridPoint(column: col, row: row)
            }
        }
        return nil
    }

    /// All 25 grid points, in column-major order.
    public static var allPoints: [GridPoint] {
        (0..<5).flatMap { col in
            (0..<5).map { row in GridPoint(column: col, row: row) }
        }
    }
}
