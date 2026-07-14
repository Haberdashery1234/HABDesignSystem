//
//  HABThemeManagerTests.swift
//  HABUIKitTests
//
//  Tests for the HABThemeManager singleton and its notification contract.
//

import XCTest
import HABUIKit

final class HABThemeManagerTests: XCTestCase {
    // MARK: - Singleton

    func testSharedIsSingleton() {
        XCTAssertIdentical(HABThemeManager.shared, HABThemeManager.shared)
    }

    func testDefaultThemeIsHABDefault() {
        // Reset to a known state before asserting name.
        HABThemeManager.shared.theme = HABDefaultTheme()
        XCTAssertEqual(HABThemeManager.shared.theme.name, "HABDefault")
    }

    // MARK: - Notification dispatch

    func testThemeChangeBroadcastsNotification() {
        let exp = expectation(description: "notification received")

        let token = NotificationCenter.default.addObserver(
            forName: HABThemeManager.themeDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            exp.fulfill()
        }
        defer { NotificationCenter.default.removeObserver(token) }

        HABThemeManager.shared.theme = HABDefaultTheme()
        waitForExpectations(timeout: 1)
    }

    func testNotificationCarriesThemeName() {
        var receivedName: String?

        let token = NotificationCenter.default.addObserver(
            forName: HABThemeManager.themeDidChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            receivedName = notification.userInfo?[HABThemeManager.themeNameKey] as? String
        }
        defer { NotificationCenter.default.removeObserver(token) }

        HABThemeManager.shared.theme = HABDefaultTheme()

        XCTAssertEqual(receivedName, HABDefaultTheme().name)
    }

    func testNotificationSenderIsManager() {
        var sender: AnyObject?

        let token = NotificationCenter.default.addObserver(
            forName: HABThemeManager.themeDidChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            sender = notification.object as AnyObject
        }
        defer { NotificationCenter.default.removeObserver(token) }

        HABThemeManager.shared.theme = HABDefaultTheme()

        XCTAssertIdentical(sender, HABThemeManager.shared)
    }

    // MARK: - Custom theme

    func testCustomThemeNameIsReflected() {
        struct TestTheme: HABTheme {
            let name = "Test"
            var colors: HABColorTokens { HABColorTokens() }
            var typography: HABTypographyTokens { HABTypographyTokens() }
        }

        HABThemeManager.shared.theme = TestTheme()
        XCTAssertEqual(HABThemeManager.shared.theme.name, "Test")

        // Restore default so other tests are unaffected.
        HABThemeManager.shared.theme = HABDefaultTheme()
    }
}
