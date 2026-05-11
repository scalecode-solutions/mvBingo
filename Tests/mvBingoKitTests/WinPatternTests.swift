import Testing
@testable import mvBingoKit

@Suite("WinPattern")
struct WinPatternTests {

    @Test func anyLineHasTwelveSets() {
        // 5 rows + 5 columns + 2 diagonals.
        #expect(WinPattern.anyLine.winningSets.count == 12)
        for set in WinPattern.anyLine.winningSets {
            #expect(set.count == 5)
        }
    }

    @Test func fourCornersHasOneSetOfFour() {
        #expect(WinPattern.fourCorners.winningSets.count == 1)
        #expect(WinPattern.fourCorners.winningSets.first?.count == 4)
    }

    @Test func xHasOneSetOfNine() {
        // Two diagonals share the center → 5 + 5 − 1 = 9 cells.
        #expect(WinPattern.x.winningSets.count == 1)
        #expect(WinPattern.x.winningSets.first?.count == 9)
    }

    @Test func plusHasOneSetOfNine() {
        // Middle row + middle column share the center → 5 + 5 − 1 = 9.
        #expect(WinPattern.plus.winningSets.count == 1)
        #expect(WinPattern.plus.winningSets.first?.count == 9)
    }

    @Test func blackoutCoversAllTwentyFive() {
        #expect(WinPattern.blackout.winningSets.count == 1)
        #expect(WinPattern.blackout.winningSets.first?.count == 25)
    }

    @Test func allPatternsHaveDistinctLabels() {
        let labels = WinPattern.allCases.map(\.label)
        #expect(Set(labels).count == labels.count)
    }
}
