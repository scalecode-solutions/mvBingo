import Testing
@testable import mvBingoKit

@Suite("BingoCard")
struct BingoCardTests {

    @Test func randomCardSatisfiesAllConstraints() {
        for _ in 0..<50 {
            let card = BingoCard.random()
            // Center is the free space.
            #expect(card.number(at: BingoCard.freeSpace) == nil)
            // Every other cell has a number in its column's range.
            for col in 0..<5 {
                let range = BingoBall.letterRanges[col]
                for row in 0..<5 {
                    let point = GridPoint(column: col, row: row)
                    if point == BingoCard.freeSpace {
                        continue
                    }
                    guard let n = card.number(at: point) else {
                        Issue.record("Missing number at \(point)")
                        continue
                    }
                    #expect(range.contains(n))
                }
            }
            // No duplicate numbers across the whole card.
            let nums = card.cells.flatMap { $0 }.compactMap { $0 }
            #expect(Set(nums).count == nums.count)
            #expect(nums.count == 24)
        }
    }

    @Test func positionOfBallFindsTheCell() {
        let card = BingoCard.random()
        // For every numbered cell, the ball that matches lives there.
        for point in BingoCard.allPoints where point != BingoCard.freeSpace {
            guard let n = card.number(at: point), let ball = BingoBall(number: n) else {
                Issue.record("Expected number at \(point)")
                continue
            }
            #expect(card.position(of: ball) == point)
        }
    }

    @Test func positionOfUncardedBallIsNil() {
        let card = BingoCard.random()
        let onCard = Set(card.cells.flatMap { $0 }.compactMap { $0 })
        guard let missing = (1...75).first(where: { !onCard.contains($0) }),
              let ball = BingoBall(number: missing) else {
            Issue.record("No off-card ball found"); return
        }
        #expect(card.position(of: ball) == nil)
    }

    @Test func invalidLayoutRejected() {
        // Wrong size
        #expect(BingoCard(cells: [[]]) == nil)
        // Center not free
        var cells: [[Int?]] = Array(repeating: Array(repeating: 1, count: 5), count: 5)
        #expect(BingoCard(cells: cells) == nil)
        // Number out of column range
        cells = Array(repeating: Array(repeating: nil, count: 5), count: 5)
        cells[0][0] = 99
        #expect(BingoCard(cells: cells) == nil)
    }

    @Test func allPointsCoversTheBoard() {
        #expect(BingoCard.allPoints.count == 25)
        #expect(Set(BingoCard.allPoints).count == 25)
    }
}
