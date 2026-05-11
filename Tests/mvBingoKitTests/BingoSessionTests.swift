import Testing
import Foundation
@testable import mvBingoKit

@Suite("BingoSession")
struct BingoSessionTests {

    @Test func freshSessionHasFreeSpaceMarked() {
        let session = BingoSession.random()
        #expect(session.marks(card: 0) == [BingoCard.freeSpace])
        #expect(session.drawn.isEmpty)
        #expect(session.status == .active)
    }

    @Test func drawNextAppendsToHistory() {
        let session = BingoSession.random()
        let drawn1 = session.drawNext()
        let drawn2 = session.drawNext()
        #expect(drawn1 != nil)
        #expect(drawn2 != nil)
        #expect(drawn1 != drawn2)
        #expect(session.drawn.count == 2)
        #expect(session.lastDrawn == drawn2)
    }

    @Test func draws75ThenReturnsNil() {
        let session = BingoSession.random()
        for _ in 0..<75 {
            #expect(session.drawNext() != nil)
        }
        #expect(session.drawNext() == nil)
        #expect(session.isExhausted)
    }

    @Test func freeSpaceCannotBeToggledOff() {
        let session = BingoSession.random()
        session.toggleMark(at: BingoCard.freeSpace)
        #expect(session.marks(card: 0).contains(BingoCard.freeSpace))
    }

    @Test func unmarkRespectsFreeSpace() {
        let session = BingoSession.random()
        session.unmark(BingoCard.freeSpace)
        #expect(session.marks(card: 0).contains(BingoCard.freeSpace))
    }

    @Test func toggleAddsAndRemovesOrdinaryCells() {
        let session = BingoSession.random()
        let point = GridPoint(column: 0, row: 0)
        #expect(!session.marks(card: 0).contains(point))
        session.toggleMark(at: point)
        #expect(session.marks(card: 0).contains(point))
        session.toggleMark(at: point)
        #expect(!session.marks(card: 0).contains(point))
    }

    @Test func isCallableOnlyAfterDraw() {
        let session = BingoSession.random()
        let point = GridPoint(column: 0, row: 0)
        guard session.card.number(at: point) != nil else { return }
        #expect(!session.isCallable(point))
        while !session.isCallable(point), !session.isExhausted {
            session.drawNext()
        }
        #expect(session.isCallable(point))
    }

    @Test func bingoDetectsACompletedRow() {
        let session = BingoSession.random()
        for col in 0..<5 {
            session.mark(GridPoint(column: col, row: 0))
        }
        #expect(session.hasBingo)
        if case .bingo(let pattern, let cells) = session.status {
            #expect(pattern == .anyLine)
            #expect(cells.count == 5)
            #expect(cells.allSatisfy { $0.row == 0 })
        } else {
            Issue.record("Expected .bingo")
        }
    }

    @Test func bingoDetectsADiagonalThroughFreeSpace() {
        let session = BingoSession.random()
        session.mark(GridPoint(column: 0, row: 0))
        session.mark(GridPoint(column: 1, row: 1))
        session.mark(GridPoint(column: 3, row: 3))
        session.mark(GridPoint(column: 4, row: 4))
        #expect(session.hasBingo)
    }

    @Test func drawNextStopsAfterBingo() {
        let session = BingoSession.random()
        for col in 0..<5 {
            session.mark(GridPoint(column: col, row: 0))
        }
        #expect(session.hasBingo)
        let before = session.drawn.count
        #expect(session.drawNext() == nil)
        #expect(session.drawn.count == before)
    }

    @Test func restartResetsDrawsAndMarks() {
        let session = BingoSession.random()
        session.drawNext()
        session.drawNext()
        session.mark(GridPoint(column: 0, row: 0))

        session.restart()

        #expect(session.drawn.isEmpty)
        #expect(session.marks(card: 0) == [BingoCard.freeSpace])
        #expect(session.status == .active)
    }

    @Test func newCardsResetsState() {
        let session = BingoSession.random()
        session.drawNext()
        session.newCards()
        #expect(session.drawn.isEmpty)
        #expect(session.marks(card: 0) == [BingoCard.freeSpace])
        #expect(session.cardCount == 1)
    }

    // MARK: - Multi-card

    @Test func randomWithCardCountClampsTo1Through4() {
        #expect(BingoSession.random(cardCount: 0).cardCount == 1)
        #expect(BingoSession.random(cardCount: 1).cardCount == 1)
        #expect(BingoSession.random(cardCount: 2).cardCount == 2)
        #expect(BingoSession.random(cardCount: 4).cardCount == 4)
        #expect(BingoSession.random(cardCount: 99).cardCount == 4)
    }

    @Test func eachCardStartsWithFreeSpaceMarked() {
        let session = BingoSession.random(cardCount: 3)
        for i in 0..<3 {
            #expect(session.marks(card: i) == [BingoCard.freeSpace])
        }
    }

    @Test func setCardCountGrowsAndShrinks() {
        let session = BingoSession.random(cardCount: 1)
        session.setCardCount(4)
        #expect(session.cardCount == 4)
        // Drawing carries across all cards (shared history).
        session.drawNext()
        #expect(session.drawn.count == 1)
        // Shrink back.
        session.setCardCount(2)
        #expect(session.cardCount == 2)
        // Drawn history persists; marks for kept cards survive.
        #expect(session.drawn.count == 1)
    }

    @Test func setCardCountClamps() {
        let session = BingoSession.random()
        session.setCardCount(99)
        #expect(session.cardCount == 4)
        session.setCardCount(-5)
        #expect(session.cardCount == 1)
    }

    @Test func autoMarkSweepsAllCalledNumbersAcrossAllCards() {
        let session = BingoSession.random(cardCount: 2)
        // Force-draw a known set of balls by repeatedly drawing until we
        // have 10, then assert auto-mark catches every match across both
        // cards.
        for _ in 0..<10 { session.drawNext() }
        session.autoMarkCalledNumbers()
        let called = Set(session.drawn.map(\.number))
        for cardIndex in 0..<session.cardCount {
            for point in BingoCard.allPoints {
                guard let n = session.cards[cardIndex].number(at: point) else {
                    continue
                }
                if called.contains(n) {
                    #expect(session.marks(card: cardIndex).contains(point))
                }
            }
        }
    }

    @Test func anyCardWinningEndsTheRound() {
        let session = BingoSession.random(cardCount: 3)
        // Force a bingo on card 1 (top row).
        for col in 0..<5 {
            session.mark(card: 1, at: GridPoint(column: col, row: 0))
        }
        #expect(session.hasBingo)
        #expect(session.firstWin?.cardIndex == 1)
        // Cards 0 and 2 don't (necessarily) have wins.
        #expect(session.wins.contains { $0.cardIndex == 1 })
    }
}
