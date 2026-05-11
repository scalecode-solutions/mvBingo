import SwiftUI
import mvBingoKit
import mvBingoUI

struct ContentView: View {
    let statsStore: any StatsStore

    var body: some View {
        BingoSessionView(statsStore: statsStore)
    }
}

#Preview {
    ContentView(statsStore: UserDefaultsStatsStore())
        .bingoTheme(.churchBasement)
        .preferredColorScheme(.dark)
}
