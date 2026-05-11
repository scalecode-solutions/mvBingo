import SwiftUI
import mvBingoKit
import mvBingoUI

@main
struct mvBingoDemoApp: App {

    /// SwiftData-backed stats store constructed once at launch.
    private let statsStore: any StatsStore

    init() {
        do {
            statsStore = try SwiftDataStatsStore()
        } catch {
            assertionFailure("SwiftDataStatsStore init failed: \(error)")
            statsStore = UserDefaultsStatsStore()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(statsStore: statsStore)
                .bingoTheme(.churchBasement)
                .preferredColorScheme(.dark)
        }
    }
}
