//
//  HABLightTheme.swift
//  HABUIKit
//
//  HABUIKit's curated light theme.
//
//  Palette concept: warm parchment backgrounds paired with Royal Blue
//  as the primary action color.
//
//  Contrast: every text color meets WCAG AA (4.5:1) against all four
//  background/surface tokens, `on*` colors meet 4.5:1 on their fills, and
//  `border` meets 3:1 as an input outline. Enforced by HABThemeContrastTests. All values are
//  hardcoded — this theme does not shift with the system appearance.
//  Pair it with HABDarkTheme and switch at runtime to support a
//  manual light/dark toggle inside your app.
//

#if canImport(UIKit)
import UIKit

public struct HABLightTheme: HABTheme {
    public let name = "HABLight"

    public var colors: HABColorTokens {
        HABColorTokens(
            // ── Brand ──────────────────────────────────────────────────────
            primary: .hab(r: 35, g: 81, b: 219),       // Royal Blue (deepened slightly for 4.5:1 text)
            secondary: .hab(r: 46, g: 111, b: 231),       // Cornflower Blue (deepened for white text)
            accent: .hab(r: 184, g: 145, b: 74),        // Antique Gold

            // ── Backgrounds ────────────────────────────────────────────────
            background: .hab(r: 250, g: 248, b: 240),       // Warm off-white
            backgroundSecondary: .hab(r: 241, g: 237, b: 224),       // Light parchment
            surface: .hab(r: 255, g: 253, b: 246),       // Near-white, warm tint
            surfaceElevated: .hab(r: 255, g: 255, b: 255),       // Pure white

            // ── Foreground ─────────────────────────────────────────────────
            foreground: .hab(r: 28, g: 25, b: 18),        // Warm near-black
            foregroundSecondary: .hab(r: 96, g: 88, b: 70),        // Medium warm brown
            foregroundTertiary: .hab(r: 112, g: 105, b: 90),       // Muted warm gray (4.5:1 — used for placeholder text)
            foregroundDisabled: .hab(r: 190, g: 184, b: 167),       // Very muted warm
            foregroundInverted: .hab(r: 255, g: 255, b: 255),       // White (on dark/brand surfaces)

            // ── On-brand ───────────────────────────────────────────────────
            onPrimary: .hab(r: 255, g: 255, b: 255),       // White on Royal Blue
            onSecondary: .hab(r: 255, g: 255, b: 255),       // White on Cornflower

            // ── Semantic states ────────────────────────────────────────────
            destructive: .hab(r: 173, g: 52, b: 39),        // Warm red (4.5:1 as text, incl. on its tint)
            destructiveSurface: .hab(r: 173, g: 52, b: 39, a: 0.12),
            success: .hab(r: 28, g: 109, b: 61),        // Forest green (4.5:1 as text, incl. on its tint)
            successSurface: .hab(r: 28, g: 109, b: 61, a: 0.12),
            warning: .hab(r: 124, g: 90, b: 25),        // Dark amber / bronze (4.5:1 as text, incl. on its tint)
            warningSurface: .hab(r: 124, g: 90, b: 25, a: 0.12),
            info: .hab(r: 35, g: 81, b: 219),       // Matches primary
            infoSurface: .hab(r: 35, g: 81, b: 219, a: 0.12),

            // ── UI Chrome ──────────────────────────────────────────────────
            border: .hab(r: 155, g: 140, b: 105),       // Warm gray (3:1 input outline)
            borderSubtle: .hab(r: 228, g: 223, b: 208),       // Very light warm gray
            overlay: .hab(r: 20, g: 16, b: 8, a: 0.4)// Warm black
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
