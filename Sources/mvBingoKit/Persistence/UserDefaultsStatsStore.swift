import Foundation

/// Default `StatsStore` backed by `UserDefaults`. Zero dependencies; fine
/// for modest stat volumes. For richer history queries swap in
/// `SwiftDataStatsStore`.
public actor UserDefaultsStatsStore: StatsStore {

    private let defaults: UserDefaults
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(suiteName: String? = nil, key: String = "dev.scalecode.mvBingo.completedGames") {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
        self.key = key
    }

    public func record(_ game: CompletedBingoGame) async {
        var games = load()
        games.append(game)
        save(games)
    }

    public func summary() async -> BingoStatsSummary {
        let games = load()
        guard !games.isEmpty else { return .empty }
        let wins = games.filter(\.didWin)
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
        let games = load().sorted { $0.date > $1.date }
        return Array(games.prefix(max(0, limit)))
    }

    public func reset() async {
        defaults.removeObject(forKey: key)
    }

    // MARK: - Helpers

    private func load() -> [CompletedBingoGame] {
        guard let data = defaults.data(forKey: key),
              let games = try? decoder.decode([CompletedBingoGame].self, from: data) else {
            return []
        }
        return games
    }

    private func save(_ games: [CompletedBingoGame]) {
        guard let data = try? encoder.encode(games) else { return }
        defaults.set(data, forKey: key)
    }
}
