import Foundation
import Observation

/// One bingo game in progress. UI binds to `@Observable` properties for
/// drawn balls, marked cells, and the current status.
///
/// The center free space is marked from the start and cannot be unmarked.
@Observable
public final class BingoSession {

    public private(set) var card: BingoCard
    public private(set) var pattern: WinPattern
    public private(set) var drawn: [BingoBall]
    public private(set) var marks: Set<GridPoint>
    public private(set) var startedAt: Date

    public init(card: BingoCard, pattern: WinPattern = .anyLine) {
        self.card = card
        self.pattern = pattern
        self.drawn = []
        self.marks = [BingoCard.freeSpace]
        self.startedAt = Date()
    }

    /// Start a session with a freshly-shuffled random card.
    public static func random(pattern: WinPattern = .anyLine) -> BingoSession {
        BingoSession(card: BingoCard.random(), pattern: pattern)
    }

    // MARK: - Draw

    /// Balls not yet drawn.
    public var undrawnBalls: [BingoBall] {
        let drawnSet = Set(drawn)
        return BingoBall.all.filter { !drawnSet.contains($0) }
    }

    /// The most recently drawn ball (the "current call"), or nil before play.
    public var lastDrawn: BingoBall? { drawn.last }

    /// Whether every ball has been drawn.
    public var isExhausted: Bool { drawn.count >= BingoBall.all.count }

    /// Draw a new random ball. No-op (returns nil) when the bag is empty or
    /// the player has already won.
    @discardableResult
    public func drawNext() -> BingoBall? {
        guard !status.hasBingo else { return nil }
        let remaining = undrawnBalls
        var rng = SystemRandomNumberGenerator()
        guard let ball = remaining.randomElement(using: &rng) else { return nil }
        drawn.append(ball)
        return ball
    }

    // MARK: - Marks

    /// Toggle the mark at `point`. The free space cannot be toggled off.
    public func toggleMark(at point: GridPoint) {
        if point == BingoCard.freeSpace { return }
        if marks.contains(point) {
            marks.remove(point)
        } else {
            marks.insert(point)
        }
    }

    public func mark(_ point: GridPoint) {
        marks.insert(point)
    }

    public func unmark(_ point: GridPoint) {
        guard point != BingoCard.freeSpace else { return }
        marks.remove(point)
    }

    /// Numbers on the card that have been called but not yet daubed.
    public var unmarkedCalledPoints: [GridPoint] {
        let calledNumbers = Set(drawn.map(\.number))
        return BingoCard.allPoints.filter { point in
            guard !marks.contains(point),
                  let n = card.number(at: point) else { return false }
            return calledNumbers.contains(n)
        }
    }

    /// Whether a given point can legally be marked (i.e., the card's number
    /// there has been called).
    public func isCallable(_ point: GridPoint) -> Bool {
        guard let n = card.number(at: point) else { return false }
        return drawn.contains(where: { $0.number == n })
    }

    // MARK: - Status

    /// The current game status, computed from the marks against the pattern's
    /// winning sets.
    public var status: BingoStatus {
        for set in pattern.winningSets where set.isSubset(of: marks) {
            return .bingo(pattern: pattern, winningCells: set)
        }
        return .active
    }

    /// True iff the current pattern has been completed.
    public var hasBingo: Bool { status.hasBingo }

    // MARK: - Restart

    /// Restart with the same card and pattern.
    public func restart() {
        drawn.removeAll()
        marks = [BingoCard.freeSpace]
        startedAt = Date()
    }

    /// Restart with a brand new random card. Pattern can optionally change.
    public func newCard(pattern: WinPattern? = nil) {
        card = BingoCard.random()
        if let pattern { self.pattern = pattern }
        drawn.removeAll()
        marks = [BingoCard.freeSpace]
        startedAt = Date()
    }

    /// Change the winning pattern mid-game. Marks and draws are preserved.
    public func setPattern(_ pattern: WinPattern) {
        self.pattern = pattern
    }
}
