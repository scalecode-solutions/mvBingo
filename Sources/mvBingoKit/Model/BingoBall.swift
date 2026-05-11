import Foundation

/// One of the 75 balls in a standard bingo draw, partitioned into the five
/// B-I-N-G-O letter ranges.
///
/// - B: 1...15
/// - I: 16...30
/// - N: 31...45
/// - G: 46...60
/// - O: 61...75
public enum BingoBall: Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    case b(Int)
    case i(Int)
    case n(Int)
    case g(Int)
    case o(Int)

    /// Letter ranges, indexed 0...4 to match `column`.
    public static let letterRanges: [ClosedRange<Int>] = [
        1...15, 16...30, 31...45, 46...60, 61...75
    ]

    /// All 75 balls, ordered B1 → O75.
    public static let all: [BingoBall] = (1...75).compactMap(BingoBall.init(number:))

    /// Construct a ball from its number, picking the right letter automatically.
    public init?(number: Int) {
        switch number {
        case 1...15:  self = .b(number)
        case 16...30: self = .i(number)
        case 31...45: self = .n(number)
        case 46...60: self = .g(number)
        case 61...75: self = .o(number)
        default: return nil
        }
    }

    /// The raw number 1...75.
    public var number: Int {
        switch self {
        case .b(let n), .i(let n), .n(let n), .g(let n), .o(let n): n
        }
    }

    /// Single-letter identifier "B", "I", "N", "G", or "O".
    public var letter: String {
        switch self {
        case .b: "B"
        case .i: "I"
        case .n: "N"
        case .g: "G"
        case .o: "O"
        }
    }

    /// Column index 0...4 (B=0, I=1, N=2, G=3, O=4).
    public var column: Int {
        switch self {
        case .b: 0
        case .i: 1
        case .n: 2
        case .g: 3
        case .o: 4
        }
    }

    /// "B-12" style label for display.
    public var label: String { "\(letter)-\(number)" }

    /// "B twelve" style text suitable for an `AVSpeechSynthesizer` utterance.
    public var spoken: String { "\(letter) \(number)" }

    public var description: String { label }

    public static func < (lhs: BingoBall, rhs: BingoBall) -> Bool {
        lhs.number < rhs.number
    }
}
