import Foundation

/// A cell position on a bingo card. Columns 0...4 map to B-I-N-G-O.
/// Rows 0...4 run top-to-bottom.
public struct GridPoint: Hashable, Sendable, Codable, CustomStringConvertible {
    public let column: Int
    public let row: Int

    public init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }

    public var description: String { "(\(column),\(row))" }
}
