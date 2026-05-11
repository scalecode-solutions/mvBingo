import SwiftUI
import mvBingoKit

/// Color palette + style knobs for the bingo UI. Themes are value types so
/// they drop straight into a SwiftUI Environment with no isolation concerns.
public struct Theme: Sendable {

    /// Behind everything.
    public var pageBackground: Color
    /// The bingo card body (paper-like).
    public var cardBackground: Color
    /// Ink color of dauber marks.
    public var dauberInk: Color
    /// Cells with the number-only state (no mark).
    public var cellText: Color
    /// Header strip behind the B-I-N-G-O letters.
    public var headerBackground: Color
    /// "B / I / N / G / O" header letters.
    public var headerText: Color
    /// Big "current call" readout background ring.
    public var lastBallRing: Color
    /// Big "current call" readout text.
    public var lastBallText: Color
    /// Primary headline color (titles, BINGO rating).
    public var headlineColor: Color
    /// Secondary body text.
    public var bodyColor: Color
    /// Tint for cells whose number has been called but isn't yet daubed.
    public var calledHighlight: Color

    public init(
        pageBackground: Color,
        cardBackground: Color,
        dauberInk: Color,
        cellText: Color,
        headerBackground: Color,
        headerText: Color,
        lastBallRing: Color,
        lastBallText: Color,
        headlineColor: Color,
        bodyColor: Color,
        calledHighlight: Color
    ) {
        self.pageBackground = pageBackground
        self.cardBackground = cardBackground
        self.dauberInk = dauberInk
        self.cellText = cellText
        self.headerBackground = headerBackground
        self.headerText = headerText
        self.lastBallRing = lastBallRing
        self.lastBallText = lastBallText
        self.headlineColor = headlineColor
        self.bodyColor = bodyColor
        self.calledHighlight = calledHighlight
    }
}

extension Theme {
    /// Church-basement bingo night: ivory card, hot-pink dauber, navy
    /// header band, soft warm page.
    public static let churchBasement = Theme(
        pageBackground: Color(red: 0.13, green: 0.10, blue: 0.16),
        cardBackground: Color(red: 0.98, green: 0.95, blue: 0.88),
        dauberInk: Color(red: 0.96, green: 0.18, blue: 0.45).opacity(0.78),
        cellText: Color(red: 0.18, green: 0.12, blue: 0.22),
        headerBackground: Color(red: 0.13, green: 0.22, blue: 0.45),
        headerText: Color(red: 0.99, green: 0.92, blue: 0.78),
        lastBallRing: Color(red: 0.96, green: 0.18, blue: 0.45),
        lastBallText: Color(red: 0.99, green: 0.92, blue: 0.78),
        headlineColor: Color(red: 0.99, green: 0.92, blue: 0.78),
        bodyColor: Color(red: 0.85, green: 0.78, blue: 0.68),
        calledHighlight: Color(red: 0.96, green: 0.78, blue: 0.18).opacity(0.32)
    )

    /// Vegas night: deep black page, gold header strip, hot-pink dauber
    /// ring, casino-floor energy.
    public static let vegasNight = Theme(
        pageBackground: Color(red: 0.05, green: 0.05, blue: 0.07),
        cardBackground: Color(red: 0.13, green: 0.10, blue: 0.15),
        dauberInk: Color(red: 1.00, green: 0.20, blue: 0.55).opacity(0.85),
        cellText: Color(red: 1.00, green: 0.86, blue: 0.40),
        headerBackground: Color(red: 0.85, green: 0.65, blue: 0.10),
        headerText: Color(red: 0.05, green: 0.05, blue: 0.07),
        lastBallRing: Color(red: 1.00, green: 0.20, blue: 0.55),
        lastBallText: Color(red: 1.00, green: 0.86, blue: 0.40),
        headlineColor: Color(red: 1.00, green: 0.86, blue: 0.40),
        bodyColor: Color(red: 0.78, green: 0.72, blue: 0.50),
        calledHighlight: Color(red: 0.85, green: 0.65, blue: 0.10).opacity(0.28)
    )

    /// Cracker Barrel: dark wood page, cream card, brown ink dauber,
    /// shared DNA with PegGame for a "Scalecode wood games" set.
    public static let crackerBarrel = Theme(
        pageBackground: Color(red: 0.12, green: 0.08, blue: 0.05),
        cardBackground: Color(red: 0.96, green: 0.90, blue: 0.78),
        dauberInk: Color(red: 0.42, green: 0.22, blue: 0.10).opacity(0.80),
        cellText: Color(red: 0.30, green: 0.18, blue: 0.08),
        headerBackground: Color(red: 0.55, green: 0.32, blue: 0.16),
        headerText: Color(red: 0.99, green: 0.92, blue: 0.78),
        lastBallRing: Color(red: 0.85, green: 0.55, blue: 0.22),
        lastBallText: Color(red: 0.99, green: 0.92, blue: 0.78),
        headlineColor: Color(red: 0.99, green: 0.92, blue: 0.78),
        bodyColor: Color(red: 0.85, green: 0.78, blue: 0.62),
        calledHighlight: Color(red: 0.96, green: 0.78, blue: 0.40).opacity(0.32)
    )

    /// Kid-friendly: bright primary blue page, white card, big red
    /// dauber, big orange header.
    public static let kidFriendly = Theme(
        pageBackground: Color(red: 0.20, green: 0.45, blue: 0.78),
        cardBackground: Color(red: 1.00, green: 1.00, blue: 0.98),
        dauberInk: Color(red: 0.96, green: 0.28, blue: 0.18).opacity(0.85),
        cellText: Color(red: 0.13, green: 0.18, blue: 0.32),
        headerBackground: Color(red: 0.95, green: 0.62, blue: 0.18),
        headerText: Color.white,
        lastBallRing: Color(red: 0.96, green: 0.28, blue: 0.18),
        lastBallText: Color.white,
        headlineColor: Color.white,
        bodyColor: Color.white.opacity(0.88),
        calledHighlight: Color(red: 1.00, green: 0.88, blue: 0.30).opacity(0.42)
    )
}

/// Named themes the user can pick from in Settings.
public enum BingoThemeName: String, CaseIterable, Sendable, Hashable, Codable, Identifiable {
    case churchBasement
    case vegasNight
    case crackerBarrel
    case kidFriendly

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .churchBasement: "Church Basement"
        case .vegasNight:     "Vegas Night"
        case .crackerBarrel:  "Cracker Barrel"
        case .kidFriendly:    "Kid Friendly"
        }
    }

    public var theme: Theme {
        switch self {
        case .churchBasement: .churchBasement
        case .vegasNight:     .vegasNight
        case .crackerBarrel:  .crackerBarrel
        case .kidFriendly:    .kidFriendly
        }
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .churchBasement
}

extension EnvironmentValues {
    public var bingoTheme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    public func bingoTheme(_ theme: Theme) -> some View {
        environment(\.bingoTheme, theme)
    }
}
