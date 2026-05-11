import SwiftUI
import mvBingoUI

@main
struct mvBingoDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .bingoTheme(.churchBasement)
                .preferredColorScheme(.dark)
        }
    }
}
