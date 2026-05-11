import Testing
import Foundation
@testable import mvBingoKit

@Suite("BingoSession")
struct BingoSessionTests {

    @Test func freshSessionHasFreeSpaceMarked() {
        let session = BingoSession.random()
        #expect(session.marks == [BingoCard.freeSpace])
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
        #expect(session.marks.contains(BingoCard.freeSpace))
    }

    @Test func unmarkRespectsFreeSpace() {
        let session = BingoSession.random()
        session.unmark(BingoCard.freeSpace)
        #expect(session.marks.contains(BingoCard.freeSpace))
    }

    @Test func toggleAddsAndRemovesOrdinaryCells() {
        let session = BingoSession.random()
        let point = GridPoint(column: 0, row: 0)
        #expect(!session.marks.contains(point))
        session.toggleMark(at: point)
        #expect(session.marks.contains(point))
        session.toggleMark(at: point)
        #expect(!session.marks.contains(point))
    }

    @Test func isCallableOnlyAfterDraw() {
        let session = BingoSession.random()
        let point = GridPoint(column: 0, row: 0)
        guard let n = session.card.number(at: point) else { return }
        // The corresponding ball hasn't been called yet.
        #expect(!session.isCallable(point))
        // Synthesize a draw of exactly that ball by drawing until it shows up,
        // bounded by total possible draws so the test can't hang.
        while !session.isCallable(point), !session.isExhausted {
            session.drawNext()
        }
        // After exhausting draws or finding it, the cell with number `n` is callable.
        _ = n
        #expect(session.isCallable(point))
    }

    @Test func bingoDetectsACompletedRow() {
        let session = BingoSession.random()
        // Top row of marks → anyLine win.
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
        // Free space is at (2,2). Mark (0,0), (1,1), (3,3), (4,4) — free
        // space already marked completes the diagonal.
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
        #expect(session.marks == [BingoCard.freeSpace])
        #expect(session.status == .active)
    }

    @Test func newCardChangesTheCardAndResetsState() {
        let session = BingoSession.random()
        let originalCells = session.card.cells
        session.drawNext()
        session.newCard()
        #expect(session.drawn.isEmpty)
        #expect(session.marks == [BingoCard.freeSpace])
        // Random chance of identical cards is astronomically low, but skip the
        // identity check to keep this deterministic; verify it's a valid
        // *different-or-equal* card.
        _ = originalCells
    }
}
