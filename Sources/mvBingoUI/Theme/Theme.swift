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
