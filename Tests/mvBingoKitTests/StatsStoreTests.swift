import Testing
import Foundation
@testable import mvBingoKit

@Suite("UserDefaultsStatsStore")
struct UserDefaultsStatsStoreTests {

    private func makeStore() -> UserDefaultsStatsStore {
        // Use a unique suite per test run to avoid bleed between tests.
        UserDefaultsStatsStore(
            suiteName: "test.mvBingo.\(UUID().uuidString)",
            key: "completed"
        )
    }

    @Test func emptyStoreReturnsEmptySummary() async {
        let store = makeStore()
        let summary = await store.summary()
        #expect(summary.gamesPlayed == 0)
        #expect(summary.gamesWon == 0)
        #expect(summary.fastestBingo == nil)
    }

    @Test func recordsAndAggregates() async {
        let store = makeStore()
        await store.record(CompletedBingoGame(
            pattern: .anyLine, cardCount: 1, ballsCalled: 27,
            winningCardIndex: 0, duration: 30
        ))
        await store.record(CompletedBingoGame(
            pattern: .blackout, cardCount: 4, ballsCalled: 72,
            winningCardIndex: 2, duration: 240
        ))
        let summary = await store.summary()
        #expect(summary.gamesPlayed == 2)
        #expect(summary.gamesWon == 2)
        #expect(summary.fastestBingo == 27)
        #expect(abs(summary.averageBallsToBingo - 49.5) < 0.01)
    }
}

@Suite("SwiftDataStatsStore")
struct SwiftDataStatsStoreTests {

    private func makeStore() throws -> SwiftDataStatsStore {
        try SwiftDataStatsStore(inMemory: true)
    }

    @Test func emptyStore() async throws {
        let store = try makeStore()
        let summary = await store.summary()
        #expect(summary.gamesPlayed == 0)
        let history = await store.history(limit: 10)
        #expect(history.isEmpty)
    }

    @Test func recordAndAggregate() async throws {
        let store = try makeStore()
        await store.record(CompletedBingoGame(
            pattern: .anyLine, cardCount: 1, ballsCalled: 18,
            winningCardIndex: 0, duration: 20
        ))
        await store.record(CompletedBingoGame(
            pattern: .x, cardCount: 2, ballsCalled: 50,
            winningCardIndex: 1, duration: 60
        ))
        let summary = await store.summary()
        #expect(summary.gamesPlayed == 2)
        #expect(summary.gamesWon == 2)
        #expect(summary.fastestBingo == 18)
        #expect(abs(summary.averageBallsToBingo - 34.0) < 0.01)
    }

    @Test func historySortedDescByDate() async throws {
        let store = try makeStore()
        let now = Date()
        await store.record(CompletedBingoGame(
            date: now.addingTimeInterval(-300),
            pattern: .anyLine, cardCount: 1, ballsCalled: 30,
            winningCardIndex: 0, duration: 40
        ))
        await store.record(CompletedBingoGame(
            date: now,
            pattern: .blackout, cardCount: 4, ballsCalled: 73,
            winningCardIndex: 3, duration: 250
        ))
        let history = await store.history(limit: 10)
        #expect(history.count == 2)
        #expect(history.first?.ballsCalled == 73)
    }

    @Test func resetClearsAll() async throws {
        let store = try makeStore()
        await store.record(CompletedBingoGame(
            pattern: .anyLine, cardCount: 1, ballsCalled: 30,
            winningCardIndex: 0, duration: 40
        ))
        await store.reset()
        let summary = await store.summary()
        #expect(summary.gamesPlayed == 0)
    }
}
