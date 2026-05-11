import Foundation
import SwiftData

/// SwiftData-backed entity for a completed bingo game.
@Model
public final class CompletedBingoGameEntity {

    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var patternRawValue: String
    public var cardCount: Int
    public var ballsCalled: Int
    /// nil when no card won (bag exhausted).
    public var winningCardIndex: Int?
    public var duration: TimeInterval

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        patternRawValue: String,
        cardCount: Int,
        ballsCalled: Int,
        winningCardIndex: Int?,
        duration: TimeInterval
    ) {
        self.id = id
        self.date = date
        self.patternRawValue = patternRawValue
        self.cardCount = cardCount
        self.ballsCalled = ballsCalled
        self.winningCardIndex = winningCardIndex
        self.duration = duration
    }

    convenience init(_ game: CompletedBingoGame) {
        self.init(
            id: game.id,
            date: game.date,
            patternRawValue: game.pattern.rawValue,
            cardCount: game.cardCount,
            ballsCalled: game.ballsCalled,
            winningCardIndex: game.winningCardIndex,
            duration: game.duration
        )
    }

    func toValue() -> CompletedBingoGame? {
        guard let pattern = WinPattern(rawValue: patternRawValue) else { return nil }
        return CompletedBingoGame(
            id: id,
            date: date,
            pattern: pattern,
            cardCount: cardCount,
            ballsCalled: ballsCalled,
            winningCardIndex: winningCardIndex,
            duration: duration
        )
    }
}

/// `StatsStore` implementation backed by SwiftData. Use when you need
/// queryable history with growth potential beyond a few hundred games.
@ModelActor
public actor SwiftDataStatsStore: StatsStore {

    /// Convenience initializer that builds the store's `ModelContainer`
    /// internally. Pass `inMemory: true` for tests / ephemeral runs.
    ///
    /// On iOS, `Library/Application Support` isn't auto-created, so this
    /// init creates it and points SwiftData at an explicit URL inside it.
    public init(inMemory: Bool = false) throws {
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        } else {
            let fm = FileManager.default
            let appSupport = try fm.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let storeURL = appSupport.appendingPathComponent("mvBingoStats.store")
            configuration = ModelConfiguration(url: storeURL)
        }
        let container = try ModelContainer(
            for: CompletedBingoGameEntity.self,
            configurations: configuration
        )
        self.modelContainer = container
        let context = ModelContext(container)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }

    // MARK: - StatsStore

    public func record(_ game: CompletedBingoGame) async {
        modelContext.insert(CompletedBingoGameEntity(game))
        try? modelContext.save()
    }

    public func summary() async -> BingoStatsSummary {
        let descriptor = FetchDescriptor<CompletedBingoGameEntity>()
        let games = (try? modelContext.fetch(descriptor)) ?? []
        guard !games.isEmpty else { return .empty }
        let wins = games.filter { $0.winningCardIndex != nil }
        let ballCounts = wins.map(\.ballsCalled)
        let fastest = ballCounts.min()
        let avg = ballCounts.isEmpty
            ? 0
            : Double(ballCounts.reduce(0, +)) / Double(ballCounts.count)
        return BingoStatsSummary(
            gamesPlayed: games.count,
            gamesWon: wins.count,
            fastestBingo: fastest,
            averageBallsToBingo: avg
        )
    }

    public func history(limit: Int) async -> [CompletedBingoGame] {
        var descriptor = FetchDescriptor<CompletedBingoGameEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = max(0, limit)
        let entities = (try? modelContext.fetch(descriptor)) ?? []
        return entities.compactMap { $0.toValue() }
    }

    public func reset() async {
        try? modelContext.delete(model: CompletedBingoGameEntity.self)
        try? modelContext.save()
    }
}
