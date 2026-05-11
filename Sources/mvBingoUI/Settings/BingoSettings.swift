import Foundation

/// Centralized keys for `@AppStorage`-backed settings. Using one constant
/// per knob keeps spellings consistent between the views that read them and
/// the settings sheet that writes them.
public enum BingoSettingsKey {
    public static let cardCount = "dev.scalecode.mvBingo.cardCount"
    public static let autoDaub = "dev.scalecode.mvBingo.autoDaub"
    public static let ballIntervalRawValue = "dev.scalecode.mvBingo.ballIntervalRawValue"
    public static let soundMuted = "dev.scalecode.mvBingo.soundMuted"
    public static let themeName = "dev.scalecode.mvBingo.themeName"
    public static let voiceEnabled = "dev.scalecode.mvBingo.voiceEnabled"
}

/// Default values, kept alongside the keys so the settings layer is the
/// single source of truth.
public enum BingoSettingsDefault {
    public static let cardCount = 1
    public static let autoDaub = false
    /// Manual (no auto-advance) by default — the player drives draws.
    public static let ballIntervalRawValue = BallInterval.manual.rawValue
    /// Sound starts muted per design.
    public static let soundMuted = true
    public static let themeName = BingoThemeName.churchBasement.rawValue
    /// Voice caller starts off; user opts in to "B 12" announcements.
    public static let voiceEnabled = false
}

/// How often the next ball is drawn automatically. `manual` means no
/// timer — the player has to tap "Next Ball" each round.
public enum BallInterval: Int, CaseIterable, Sendable, Hashable, Codable, Identifiable {
    case manual = 0
    case fiveSeconds = 5
    case tenSeconds = 10
    case fifteenSeconds = 15
    case twentySeconds = 20

    public var id: Int { rawValue }

    /// Time between draws in seconds. `nil` for manual mode.
    public var seconds: TimeInterval? {
        self == .manual ? nil : TimeInterval(rawValue)
    }

    public var isManual: Bool { self == .manual }

    public var label: String {
        switch self {
        case .manual:         "Manual"
        case .fiveSeconds:    "5 seconds"
        case .tenSeconds:     "10 seconds"
        case .fifteenSeconds: "15 seconds"
        case .twentySeconds:  "20 seconds"
        }
    }

    public var shortLabel: String {
        switch self {
        case .manual:         "Manual"
        case .fiveSeconds:    "5s"
        case .tenSeconds:     "10s"
        case .fifteenSeconds: "15s"
        case .twentySeconds:  "20s"
        }
    }
}
