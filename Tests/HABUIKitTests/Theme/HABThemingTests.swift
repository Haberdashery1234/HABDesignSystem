//
//  HABThemingTests.swift
//  HABUIKitTests
//
//  How themes reach the UI: dynamic colors, the theme trait, threading, and
//  themeable radius / shadow / motion tokens.
//

import XCTest
import UIKit
import HABUIKit // re-exports HABFoundation

final class HABThemingTests: XCTestCase {
    override func tearDown() {
        HABThemeManager.shared.theme = HABDefaultTheme()
        super.tearDown()
    }

    private let light = UITraitCollection(userInterfaceStyle: .light)
    private let dark = UITraitCollection(userInterfaceStyle: .dark)

    // MARK: - Dynamic colors

    func testColorAssignedBeforeThemeChangeFollowsNewTheme() {
        let view = UIView()
        view.backgroundColor = .habSurface   // assigned once, never re-assigned

        HABThemeManager.shared.theme = HABDarkTheme()

        XCTAssertEqual(view.backgroundColor?.resolvedColor(with: light), HABDarkTheme().colors.surface)
    }

    func testThemedColorsAreStableInstances() {
        XCTAssertIdentical(UIColor.habPrimary, UIColor.habPrimary)
        XCTAssertIdentical(UIColor.habBorder, UIColor.habBorder)
    }

    func testAdaptiveThemeColorsStillFollowAppearance() {
        HABThemeManager.shared.theme = HABAppleTheme()
        XCTAssertEqual(
            UIColor.habBackground.resolvedColor(with: dark),
            UIColor.systemBackground.resolvedColor(with: dark)
        )
        XCTAssertEqual(
            UIColor.habBackground.resolvedColor(with: light),
            UIColor.systemBackground.resolvedColor(with: light)
        )
    }

    func testThemeTraitDefaultsToZero() {
        XCTAssertEqual(UITraitCollection().habThemeRevision, 0)
        XCTAssertTrue(HABThemeTrait.affectsColorAppearance)
    }

    // MARK: - Threading

    func testNotificationArrivesOnMainWhenThemeSetOffMain() {
        let received = expectation(description: "notification on main thread")
        let token = NotificationCenter.default.addObserver(
            forName: HABThemeManager.themeDidChangeNotification, object: nil, queue: nil
        ) { _ in
            XCTAssertTrue(Thread.isMainThread)
            received.fulfill()
        }
        defer { NotificationCenter.default.removeObserver(token) }

        DispatchQueue.global().async {
            HABThemeManager.shared.theme = HABDarkTheme()
        }
        wait(for: [received], timeout: 2)
        XCTAssertEqual(HABThemeManager.shared.theme.name, "HABDark")
    }

    func testConcurrentReadsAndWritesAreSafe() {
        let themes: [any HABTheme] = [HABLightTheme(), HABDarkTheme(), HABAppleTheme()]
        DispatchQueue.concurrentPerform(iterations: 500) { i in
            if i % 5 == 0 {
                HABThemeManager.shared.theme = themes[i % themes.count]
            } else {
                _ = HABThemeManager.shared.theme.colors.primary
            }
        }
        // Let the queued main-thread broadcasts drain before tearDown.
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
    }

    // MARK: - Themeable tokens

    func testDefaultTokensMatchLibraryConstants() {
        let theme: any HABTheme = HABLightTheme()
        XCTAssertEqual(theme.radius, HABRadiusTokens())
        XCTAssertEqual(theme.radius.lg, HABRadius.lg)
        XCTAssertEqual(theme.motion.normal, HABAnimation.Duration.normal)
        XCTAssertEqual(theme.motion.gentleSpring, HABAnimation.Spring.gentle)
        XCTAssertEqual(theme.shadows.medium.radius, HABShadow.medium.radius)
    }

    func testCustomRadiusReachesComponents() {
        let card = HABCard()
        XCTAssertEqual(card.layer.cornerRadius, HABRadius.lg)

        HABThemeManager.shared.theme = RoundedTheme()

        XCTAssertEqual(card.layer.cornerRadius, 30, "existing card updates on theme change")
        XCTAssertEqual(HABCard().layer.cornerRadius, 30, "new card uses the theme's radius")
    }

    func testCustomShadowReachesComponents() {
        HABThemeManager.shared.theme = RoundedTheme()
        let card = HABCard(style: .elevated)
        XCTAssertEqual(card.layer.shadowRadius, 2)
    }
}

/// A theme that only overrides what it needs; everything else uses defaults.
private struct RoundedTheme: HABTheme {
    let name = "Rounded"
    let colors = HABColorTokens()
    let typography = HABTypographyTokens()
    let radius = HABRadiusTokens(lg: 30)
    let shadows = HABShadowTokens(
        low: HABShadowStyle(color: .black, opacity: 0.2, radius: 2, offset: .zero)
    )
}
