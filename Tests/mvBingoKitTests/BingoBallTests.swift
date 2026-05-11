import Testing
@testable import mvBingoKit

@Suite("BingoBall")
struct BingoBallTests {

    @Test func numberRoundTrip() {
        for n in 1...75 {
            let ball = BingoBall(number: n)
            #expect(ball?.number == n)
        }
    }

    @Test func outOfRangeReturnsNil() {
        #expect(BingoBall(number: 0) == nil)
        #expect(BingoBall(number: 76) == nil)
        #expect(BingoBall(number: -5) == nil)
    }

    @Test func lettersMatchRanges() {
        #expect(BingoBall(number: 1)?.letter == "B")
        #expect(BingoBall(number: 15)?.letter == "B")
        #expect(BingoBall(number: 16)?.letter == "I")
        #expect(BingoBall(number: 30)?.letter == "I")
        #expect(BingoBall(number: 31)?.letter == "N")
        #expect(BingoBall(number: 45)?.letter == "N")
        #expect(BingoBall(number: 46)?.letter == "G")
        #expect(BingoBall(number: 60)?.letter == "G")
        #expect(BingoBall(number: 61)?.letter == "O")
        #expect(BingoBall(number: 75)?.letter == "O")
    }

    @Test func columnsMatchLetters() {
        #expect(BingoBall(number: 5)?.column == 0)
        #expect(BingoBall(number: 20)?.column == 1)
        #expect(BingoBall(number: 35)?.column == 2)
        #expect(BingoBall(number: 50)?.column == 3)
        #expect(BingoBall(number: 70)?.column == 4)
    }

    @Test func allContains75() {
        #expect(BingoBall.all.count == 75)
        #expect(Set(BingoBall.all).count == 75)
    }

    @Test func spokenAndLabelFormats() {
        let ball = BingoBall(number: 12)!
        #expect(ball.label == "B-12")
        #expect(ball.spoken == "B 12")
    }
}
