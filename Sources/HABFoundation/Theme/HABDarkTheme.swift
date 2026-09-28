//
//  HABDarkTheme.swift
//  HABUIKit
//
//  HABUIKit's curated dark theme.
//
//  Palette concept: deep navy backgrounds (echoing the Royal Blue
//  family), a slightly brightened primary for contrast on dark
//  surfaces, and parchment-tinted foreground colors so text retains
//  warmth rather than going cold white.
//
//  Contrast: every text color meets WCAG AA (4.5:1) against all four
//  background/surface tokens, `on*` colors meet 4.5:1 on their fills, and
//  `border` meets 3:1 as an input outline. Enforced by HABThemeContrastTests.
//  On dark navy, no blue can pass both as text on the background and under
//  white text, so buttons use dark text (`on*` = warm near-black).
//
//  All values are hardcoded — this theme does not shift with the
//  system appearance. Set it explicitly when you want a forced dark
//  experience, or swap from HABLightTheme in response to a user toggle.
//

#if canImport(UIKit)
import UIKit

public struct HABDarkTheme: HABTheme {
    public let name = "HABDark"

    public var colors: HABColorTokens {
        HABColorTokens(
            // ── Brand ──────────────────────────────────────────────────────
            primary: .hab(r: 137, g: 167, b: 244),       // Brightened Royal Blue (dark-mode contrast)
            secondary: .hab(r: 120, g: 160, b: 245),       // Light Cornflower
            accent: .hab(r: 212, g: 175, b: 96),        // Brighter Antique Gold

            // ── Backgrounds ────────────────────────────────────────────────
            background: .hab(r: 12, g: 15, b: 24),        // Deep navy
            backgroundSecondary: .hab(r: 20, g: 24, b: 38),        // Dark navy
            surface: .hab(r: 26, g: 31, b: 48),        // Navy surface
            surfaceElevated: .hab(r: 36, g: 42, b: 64),        // Lighter navy

            // ── Foreground ─────────────────────────────────────────────────
            foreground: .hab(r: 242, g: 240, b: 232),       // Parchment white
            foregroundSecondary: .hab(r: 180, g: 174, b: 156),       // Muted parchment
            foregroundTertiary: .hab(r: 153, g: 147, b: 130),        // Muted parchment (4.5:1 — used for placeholder text)
            foregroundDisabled: .hab(r: 75, g: 70, b: 58),        // Very muted
            foregroundInverted: .hab(r: 28, g: 25, b: 18),        // Warm dark (text on light surfaces)

            // ── On-brand ───────────────────────────────────────────────────
            onPrimary: .hab(r: 28, g: 25, b: 18),          // Warm dark on brightened Blue
            onSecondary: .hab(r: 28, g: 25, b: 18),        // Warm dark on Light Cornflower
            onDestructive: .hab(r: 28, g: 25, b: 18),      // Warm dark on bright red

            // ── Semantic states ────────────────────────────────────────────
            destructive: .hab(r: 240, g: 139, b: 129),        // Bright coral red (4.5:1 as text, incl. on its tint)
            destructiveSurface: .hab(r: 240, g: 139, b: 129, a: 0.15),
            success: .hab(r: 46, g: 204, b: 113),       // Bright green
            successSurface: .hab(r: 46, g: 204, b: 113, a: 0.15),
            warning: .hab(r: 241, g: 196, b: 15),        // Bright amber
            warningSurface: .hab(r: 241, g: 196, b: 15, a: 0.15),
            info: .hab(r: 137, g: 167, b: 244),       // Matches primary
            infoSurface: .hab(r: 137, g: 167, b: 244, a: 0.15),

            // ── UI Chrome ──────────────────────────────────────────────────
            border: .hab(r: 94, g: 106, b: 150),        // Slate navy (3:1 input outline)
            borderSubtle: .hab(r: 35, g: 40, b: 60),        // Darker border
            overlay: .hab(r: 0, g: 0, b: 0, a: 0.6)// Deeper overlay on dark
        )
    }

    public var typography: HABTypographyTokens { HABTypographyTokens() }

    public init() {}
}

// MARK: - Private color helper

private extension UIColor {
    /// Convenience init using 0–255 integer components.
    static func hab(r: Int, g: Int, b: Int, a: CGFloat = 1) -> UIColor {
        UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: a
        )
    }
}
#endif
