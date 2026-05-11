import SwiftUI
import mvBingoKit
import mvBingoUI

struct ContentView: View {
    var body: some View {
        BingoSessionView()
    }
}

#Preview {
    ContentView()
        .bingoTheme(.churchBasement)
        .preferredColorScheme(.dark)
}
