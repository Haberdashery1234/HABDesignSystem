//
//  HABThemeContrastTests.swift
//  HABUIKitTests
//
//  WCAG 2.x contrast checks for the curated themes (HABLightTheme,
//  HABDarkTheme), covering the pairings HABUIKit components actually draw:
//
//  • Text colors on every background/surface token ........... 4.5:1 (AA text)
//  • `on*` content colors on their fills (buttons, badges) .... 4.5:1
//  • Semantic text on its own tinted surface (tags) ........... 4.5:1
//  • `border` as an input outline ............................. 3:1 (AA non-text)
//
//  HABAppleTheme is intentionally excluded: it mirrors Apple's system colors,
//  which don't all meet these ratios by default (they improve when the user
//  turns on Increase Contrast).
//

import XCTest
import UIKit
import HABFoundation
import HABUIKit

final class HABThemeContrastTests: XCTestCase {
    private let themes: [any HABTheme] = [HABLightTheme(), HABDarkTheme()]

    /// Curated themes use fixed colors, but resolve under both appearances anyway
    /// so a future adaptive token can't slip past the test.
    private let appearances: [UITraitCollection] = [
        UITraitCollection(userInterfaceStyle: .light),
        UITraitCollection(userInterfaceStyle: .dark)
    ]

    // MARK: - Text

    func testTextColorsMeetAAOnEveryBackground() {
        for theme in themes {
            let c = theme.colors
            let texts: [(String, UIColor)] = [
                ("foreground", c.foreground),
                ("foregroundSecondary", c.foregroundSecondary),
                ("foregroundTertiary", c.foregroundTertiary),
                ("primary", c.primary),
                ("destructive", c.destructive),
                ("success", c.success),
                ("warning", c.warning),
                ("info", c.info)
            ]
            for (textName, text) in texts {
                for (bgName, bg) in backgrounds(of: c) {
                    assertContrast(text, on: bg, atLeast: 4.5, "\(theme.name): \(textName) on \(bgName)")
                }
            }
        }
    }

    // MARK: - Content on fills

    func testOnColorsMeetAAOnTheirFills() {
        for theme in themes {
            let c = theme.colors
            assertContrast(c.onPrimary, on: c.primary, atLeast: 4.5, "\(theme.name): onPrimary on primary")
            assertContrast(c.onSecondary, on: c.secondary, atLeast: 4.5, "\(theme.name): onSecondary on secondary")
            assertContrast(c.onDestructive, on: c.destructive, atLeast: 4.5, "\(theme.name): onDestructive on destructive")
        }
    }

    // MARK: - Semantic text on its own tint (HABTag .filled, HABBanner)

    func testSemanticTextMeetsAAOnItsOwnTint() {
        struct SemanticPair {
            let name: String
            let text: UIColor
            let tint: UIColor
        }
        
        for theme in themes {
            let c = theme.colors
            let pairs: [SemanticPair] = [
                SemanticPair(name: "destructive", text: c.destructive, tint: c.destructiveSurface),
                SemanticPair(name: "success", text: c.success, tint: c.successSurface),
                SemanticPair(name: "warning", text: c.warning, tint: c.warningSurface),
                SemanticPair(name: "info", text: c.info, tint: c.infoSurface),
                // HABTag's .primary color uses primary at 12% as its fill.
                SemanticPair(name: "primary", text: c.primary, tint: c.primary.withAlphaComponent(0.12))
            ]
            for pair in pairs {
                for (bgName, bg) in backgrounds(of: c) {
                    assertContrast(pair.text, on: pair.tint, over: bg, atLeast: 4.5, "\(theme.name): \(pair.name) on its tint over \(bgName)")
                }
            }
        }
    }

    // MARK: - Non-text

    func testInputBorderMeetsNonTextContrast() {
        for theme in themes {
            let c = theme.colors
            assertContrast(c.border, on: c.background, atLeast: 3, "\(theme.name): border on background")
            assertContrast(c.border, on: c.surface, atLeast: 3, "\(theme.name): border on surface")
        }
    }

    // MARK: - Helpers

    private func backgrounds(of c: HABColorTokens) -> [(String, UIColor)] {
        [
            ("background", c.background),
            ("backgroundSecondary", c.backgroundSecondary),
            ("surface", c.surface),
            ("surfaceElevated", c.surfaceElevated)
        ]
    }

    /// Asserts WCAG contrast of `foreground` against `background`. A translucent
    /// background is first composited over `base`; a translucent foreground over the result.
    private func assertContrast(
        _ foreground: UIColor,
        on background: UIColor,
        over base: UIColor = .white,
        atLeast minimum: Double,
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for traits in appearances {
            let baseRGB = rgba(base, traits).opaque(over: RGB(r: 1, g: 1, b: 1))
            let bgRGB = rgba(background, traits).opaque(over: baseRGB)
            let fgRGB = rgba(foreground, traits).opaque(over: bgRGB)
            let ratio = contrastRatio(fgRGB, bgRGB)
            XCTAssertGreaterThanOrEqual(
                ratio, minimum,
                "\(label) is \(String(format: "%.2f", ratio)):1, needs \(minimum):1",
                file: file, line: line
            )
        }
    }

    private struct RGB { var r, g, b: Double }
    private struct RGBA {
        var r, g, b, a: Double
        func opaque(over bg: RGB) -> RGB {
            RGB(r: r * a + bg.r * (1 - a), g: g * a + bg.g * (1 - a), b: b * a + bg.b * (1 - a))
        }
    }

    private func rgba(_ color: UIColor, _ traits: UITraitCollection) -> RGBA {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.resolvedColor(with: traits).getRed(&r, green: &g, blue: &b, alpha: &a)
        return RGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
    }

    private func luminance(_ c: RGB) -> Double {
        func channel(_ v: Double) -> Double {
            v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b)
    }

    private func contrastRatio(_ a: RGB, _ b: RGB) -> Double {
        let (hi, lo) = (max(luminance(a), luminance(b)), min(luminance(a), luminance(b)))
        return (hi + 0.05) / (lo + 0.05)
    }
}
