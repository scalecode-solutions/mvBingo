import Foundation

/// The current state of a bingo game.
public enum BingoStatus: Hashable, Sendable {
    /// Play is ongoing; no winning pattern yet.
    case active
    /// The current pattern has been completed.
    case bingo(pattern: WinPattern, winningCells: Set<GridPoint>)

    public var hasBingo: Bool {
        if case .bingo = self { return true }
        return false
    }

    public var isActive: Bool { !hasBingo }
}
