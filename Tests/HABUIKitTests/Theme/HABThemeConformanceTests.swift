//
//  HABThemeConformanceTests.swift
//  HABUIKitTests
//
//  Verifies the four built-in HABTheme conformances: correct names,
//  accessible tokens, and distinguishable color values across themes.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABThemeConformanceTests: XCTestCase {

    // MARK: - Theme Names

    func testDefaultThemeName() {
        XCTAssertEqual(HABDefaultTheme().name, "HABDefault")
    }

    func testAppleThemeName() {
        XCTAssertEqual(HABAppleTheme().name, "HABApple")
    }

    func testLightThemeName() {
        XCTAssertEqual(HABLightTheme().name, "HABLight")
    }

    func testDarkThemeName() {
        XCTAssertEqual(HABDarkTheme().name, "HABDark")
    }

    // MARK: - Token Accessibility

    func testAllThemesProduceAccessibleColorTokens() {
        let themes: [any HABTheme] = [
            HABDefaultTheme(), HABAppleTheme(), HABLightTheme(), HABDarkTheme()
        ]
        for theme in themes {
            let c = theme.colors
            XCTAssertNotNil(c.primary,     "\(theme.name): primary is nil")
            XCTAssertNotNil(c.destructive, "\(theme.name): destructive is nil")
            XCTAssertNotNil(c.overlay,     "\(theme.name): overlay is nil")
        }
    }

    func testAllThemesProduceAccessibleTypographyTokens() {
        let themes: [any HABTheme] = [
            HABDefaultTheme(), HABAppleTheme(), HABLightTheme(), HABDarkTheme()
        ]
        for theme in themes {
            let t = theme.typography
            XCTAssertNotNil(t.display.font,  "\(theme.name): display is nil")
            XCTAssertNotNil(t.body.font,     "\(theme.name): body is nil")
            XCTAssertNotNil(t.caption2.font, "\(theme.name): caption2 is nil")
        }
    }

    // MARK: - Cross-Theme Color Differences

    /// HABLightTheme uses Royal Blue as primary; HABAppleTheme uses system blue.
    func testLightThemePrimaryDiffersFromAppleTheme() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        let light = HABLightTheme().colors.primary.resolvedColor(with: traits)
        let apple = HABAppleTheme().colors.primary.resolvedColor(with: traits)
        XCTAssertNotEqual(light, apple)
    }

    /// HABLightTheme and HABDarkTheme are designed as a contrasting pair.
    func testLightAndDarkThemeBackgroundsDiffer() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        let lightBg = HABLightTheme().colors.background.resolvedColor(with: traits)
        let darkBg  = HABDarkTheme().colors.background.resolvedColor(with: traits)
        XCTAssertNotEqual(lightBg, darkBg)
    }
}
