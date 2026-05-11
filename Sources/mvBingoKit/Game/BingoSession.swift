import Foundation
import Observation

/// One bingo game in progress. UI binds to `@Observable` properties for
/// drawn balls, per-card marks, and the current status.
///
/// Supports 1...4 cards. All cards share the same draw history; each card
/// has its own marks. Any card completing the pattern ends the round.
///
/// The center free space on each card is marked from the start and cannot
/// be unmarked.
@Observable
public final class BingoSession {

    /// Maximum number of cards a single session can hold.
    public static let maxCards = 4

    public private(set) var cards: [BingoCard]
    public private(set) var pattern: WinPattern
    public private(set) var drawn: [BingoBall]
    /// Parallel array to `cards`: `marks[i]` is the mark set for `cards[i]`.
    public private(set) var marks: [Set<GridPoint>]
    public private(set) var startedAt: Date

    public init(cards: [BingoCard], pattern: WinPattern = .anyLine) {
        precondition(!cards.isEmpty, "BingoSession needs at least one card")
        precondition(cards.count <= Self.maxCards, "At most \(Self.maxCards) cards")
        self.cards = cards
        self.pattern = pattern
        self.drawn = []
        self.marks = cards.map { _ in [BingoCard.freeSpace] }
        self.startedAt = Date()
    }

    /// Convenience for single-card play.
    public convenience init(card: BingoCard, pattern: WinPattern = .anyLine) {
        self.init(cards: [card], pattern: pattern)
    }

    /// Start a session with `count` (1...4) freshly-shuffled random cards.
    public static func random(
        cardCount: Int = 1,
        pattern: WinPattern = .anyLine
    ) -> BingoSession {
        let clamped = max(1, min(Self.maxCards, cardCount))
        let cards = (0..<clamped).map { _ in BingoCard.random() }
        return BingoSession(cards: cards, pattern: pattern)
    }

    /// Convenience for the most common single-card case.
    public var card: BingoCard { cards[0] }

    public var cardCount: Int { cards.count }

    // MARK: - Draw

    public var undrawnBalls: [BingoBall] {
        let drawnSet = Set(drawn)
        return BingoBall.all.filter { !drawnSet.contains($0) }
    }

    public var lastDrawn: BingoBall? { drawn.last }
    public var isExhausted: Bool { drawn.count >= BingoBall.all.count }

    /// Draw a new random ball. No-op (returns nil) when the bag is empty or
    /// any card has already won.
    @discardableResult
    public func drawNext() -> BingoBall? {
        guard !status.hasBingo else { return nil }
        let remaining = undrawnBalls
        var rng = SystemRandomNumberGenerator()
        guard let ball = remaining.randomElement(using: &rng) else { return nil }
        drawn.append(ball)
        return ball
    }

    /// Auto-daub every card: mark every point whose number is in the drawn
    /// set. Idempotent — call after each draw when auto-daub is on.
    public func autoMarkCalledNumbers() {
        let called = Set(drawn.map(\.number))
        for (cardIndex, card) in cards.enumerated() {
            for point in BingoCard.allPoints {
                guard !marks[cardIndex].contains(point),
                      let n = card.number(at: point),
                      called.contains(n) else { continue }
                marks[cardIndex].insert(point)
            }
        }
    }

    // MARK: - Marks

    public func toggleMark(card cardIndex: Int, at point: GridPoint) {
        guard cards.indices.contains(cardIndex) else { return }
        if point == BingoCard.freeSpace { return }
        if marks[cardIndex].contains(point) {
            marks[cardIndex].remove(point)
        } else {
            marks[cardIndex].insert(point)
        }
    }

    public func mark(card cardIndex: Int, at point: GridPoint) {
        guard cards.indices.contains(cardIndex) else { return }
        marks[cardIndex].insert(point)
    }

    public func unmark(card cardIndex: Int, at point: GridPoint) {
        guard cards.indices.contains(cardIndex) else { return }
        guard point != BingoCard.freeSpace else { return }
        marks[cardIndex].remove(point)
    }

    /// Convenience for single-card sessions: toggles mark on card 0.
    public func toggleMark(at point: GridPoint) {
        toggleMark(card: 0, at: point)
    }

    /// Convenience for single-card sessions: marks card 0.
    public func mark(_ point: GridPoint) {
        mark(card: 0, at: point)
    }

    /// Convenience for single-card sessions: unmarks card 0.
    public func unmark(_ point: GridPoint) {
        unmark(card: 0, at: point)
    }

    /// Convenience for single-card sessions: checks card 0.
    public func isCallable(_ point: GridPoint) -> Bool {
        isCallable(card: 0, point)
    }

    /// Numbers on the given card that have been called but not yet daubed.
    public func unmarkedCalledPoints(card cardIndex: Int) -> [GridPoint] {
        guard cards.indices.contains(cardIndex) else { return [] }
        let called = Set(drawn.map(\.number))
        let card = cards[cardIndex]
        let cardMarks = marks[cardIndex]
        return BingoCard.allPoints.filter { point in
            guard !cardMarks.contains(point),
                  let n = card.number(at: point) else { return false }
            return called.contains(n)
        }
    }

    public func isCallable(card cardIndex: Int, _ point: GridPoint) -> Bool {
        guard cards.indices.contains(cardIndex) else { return false }
        guard let n = cards[cardIndex].number(at: point) else { return false }
        return drawn.contains(where: { $0.number == n })
    }

    /// Marks for the given card. Empty array fallback for invalid indices.
    public func marks(card cardIndex: Int) -> Set<GridPoint> {
        guard cards.indices.contains(cardIndex) else { return [] }
        return marks[cardIndex]
    }

    // MARK: - Status

    /// All cards that have completed the pattern. Empty array → game still in
    /// play. Multiple entries possible if two cards complete on the same draw.
    public var wins: [CardWin] {
        var result: [CardWin] = []
        for (cardIndex, cardMarks) in marks.enumerated() {
            if let set = pattern.winningSets.first(where: { $0.isSubset(of: cardMarks) }) {
                result.append(CardWin(
                    cardIndex: cardIndex,
                    pattern: pattern,
                    winningCells: set
                ))
            }
        }
        return result
    }

    /// First card to win (lowest index). nil if no bingo yet.
    public var firstWin: CardWin? { wins.first }

    public var status: BingoStatus {
        if let first = firstWin {
            return .bingo(pattern: first.pattern, winningCells: first.winningCells)
        }
        return .active
    }

    public var hasBingo: Bool { status.hasBingo }

    /// Convenience: is this point part of any winning set on its card?
    public func isWinningCell(card cardIndex: Int, _ point: GridPoint) -> Bool {
        guard let win = wins.first(where: { $0.cardIndex == cardIndex }) else {
            return false
        }
        return win.winningCells.contains(point)
    }

    // MARK: - Restart / reshuffle

    /// Restart with the same cards and pattern. Clears draws and marks.
    public func restart() {
        drawn.removeAll()
        marks = cards.map { _ in [BingoCard.freeSpace] }
        startedAt = Date()
    }

    /// Replace all cards with fresh random ones. Pattern can optionally
    /// change; `cardCount` defaults to the current count.
    public func newCards(count: Int? = nil, pattern: WinPattern? = nil) {
        let target = max(1, min(Self.maxCards, count ?? cards.count))
        cards = (0..<target).map { _ in BingoCard.random() }
        marks = cards.map { _ in [BingoCard.freeSpace] }
        drawn.removeAll()
        if let pattern { self.pattern = pattern }
        startedAt = Date()
    }

    /// Resize the card stack mid-game. Adding cards: new ones are random,
    /// free-space-only marks, and they see the existing draw history.
    /// Removing cards: trims from the end.
    public func setCardCount(_ count: Int) {
        let target = max(1, min(Self.maxCards, count))
        if target == cards.count { return }
        if target < cards.count {
            cards = Array(cards.prefix(target))
            marks = Array(marks.prefix(target))
        } else {
            let toAdd = target - cards.count
            for _ in 0..<toAdd {
                cards.append(BingoCard.random())
                marks.append([BingoCard.freeSpace])
            }
        }
    }

    public func setPattern(_ pattern: WinPattern) {
        self.pattern = pattern
    }
}

/// Record of a single card winning the current pattern.
public struct CardWin: Hashable, Sendable {
    public let cardIndex: Int
    public let pattern: WinPattern
    public let winningCells: Set<GridPoint>
}
