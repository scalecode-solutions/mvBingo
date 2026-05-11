import Foundation

/// A finished bingo game, suitable for stats aggregation.
public struct CompletedBingoGame: Sendable, Hashable, Codable, Identifiable {
    public let id: UUID
    public let date: Date
    public let pattern: WinPattern
    public let cardCount: Int
    /// How many balls had been called when the game ended.
    public let ballsCalled: Int
    /// Which card won (0-indexed), or nil if the bag was exhausted with no bingo.
    public let winningCardIndex: Int?
    public let duration: TimeInterval

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        pattern: WinPattern,
        cardCount: Int,
        ballsCalled: Int,
        winningCardIndex: Int?,
        duration: TimeInterval
    ) {
        self.id = id
        self.date = date
        self.pattern = pattern
        self.cardCount = cardCount
        self.ballsCalled = ballsCalled
        self.winningCardIndex = winningCardIndex
        self.duration = duration
    }

    public var didWin: Bool { winningCardIndex != nil }
}

/// Aggregate stats over many `CompletedBingoGame`s.
public struct BingoStatsSummary: Sendable, Hashable, Codable {
    public let gamesPlayed: Int
    public let gamesWon: Int
    /// Fewest balls called to bingo. nil when no wins yet.
    public let fastestBingo: Int?
    /// Average balls called to bingo across winning games. 0 when no wins.
    public let averageBallsToBingo: Double

    public static let empty = BingoStatsSummary(
        gamesPlayed: 0,
        gamesWon: 0,
        fastestBingo: nil,
        averageBallsToBingo: 0
    )

    public init(
        gamesPlayed: Int,
        gamesWon: Int,
        fastestBingo: Int?,
        averageBallsToBingo: Double
    ) {
        self.gamesPlayed = gamesPlayed
        self.gamesWon = gamesWon
        self.fastestBingo = fastestBingo
        self.averageBallsToBingo = averageBallsToBingo
    }
}

/// Persistence backend for completed-game records.
public protocol StatsStore: Sendable {
    func record(_ game: CompletedBingoGame) async
    func summary() async -> BingoStatsSummary
    func history(limit: Int) async -> [CompletedBingoGame]
    func reset() async
}
