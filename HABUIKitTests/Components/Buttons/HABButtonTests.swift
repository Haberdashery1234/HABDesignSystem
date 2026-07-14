//
//  HABButtonTests.swift
//  HABUIKitTests
//
//  Tests for HABButton.
//

import XCTest
import HABUIKit

final class HABButtonTests: XCTestCase {
    func testInitStyle() {
        let button = HABButton(style: .primary)
        XCTAssertEqual(button.style, .primary)
    }

    func testInitWithTitle() {
        let button = HABButton(style: .secondary, size: .medium, title: "Continue")
        XCTAssertEqual(button.title, "Continue")
    }

    func testAllStyles() {
        for style in [HABButton.Style.primary, .secondary, .ghost, .destructive] {
            let button = HABButton(style: style)
            XCTAssertEqual(button.style, style)
        }
    }

    func testAllSizes() {
        for size in [HABButton.Size.small, .medium, .large] {
            let button = HABButton(style: .primary, size: size)
            XCTAssertEqual(button.size, size)
        }
    }

    func testStyleMutation() {
        let button = HABButton(style: .primary)
        button.style = .destructive
        XCTAssertEqual(button.style, .destructive)
    }

    func testSizeMutation() {
        let button = HABButton(style: .primary)
        button.size = .large
        XCTAssertEqual(button.size, .large)
    }

    func testTitleMutation() {
        let button = HABButton(style: .primary, title: "Old")
        button.title = "New"
        XCTAssertEqual(button.title, "New")
    }

    func testIsEnabledDefault() {
        let button = HABButton(style: .primary, title: "Tap")
        XCTAssertTrue(button.isEnabled)
    }

    func testIsEnabledMutation() {
        let button = HABButton(style: .primary)
        button.isEnabled = false
        XCTAssertFalse(button.isEnabled)
    }

    func testIsLoadingDefault() {
        let button = HABButton(style: .primary)
        XCTAssertFalse(button.isLoading)
    }

    func testIsLoadingMutation() {
        let button = HABButton(style: .primary)
        button.isLoading = true
        XCTAssertTrue(button.isLoading)
    }

    func testIconPositionDefault() {
        let button = HABButton(style: .primary)
        XCTAssertEqual(button.iconPosition, .leading)
    }

    func testIconPositionMutation() {
        let button = HABButton(style: .primary)
        button.iconPosition = .trailing
        XCTAssertEqual(button.iconPosition, .trailing)
    }

    func testIconPositionAbove() {
        let button = HABButton(style: .primary)
        button.iconPosition = .above
        XCTAssertEqual(button.iconPosition, .above)
    }

    func testIconPositionBelow() {
        let button = HABButton(style: .primary)
        button.iconPosition = .below
        XCTAssertEqual(button.iconPosition, .below)
    }

    func testIconMutation() {
        let button = HABButton(style: .primary)
        button.icon = UIImage(systemName: "star")
        XCTAssertNotNil(button.icon)
    }

    func testIsLoadingAccessibilityLabel() {
        let button = HABButton(style: .primary, title: "Submit")
        button.isLoading = true
        XCTAssertEqual(button.accessibilityLabel, "Loading")
    }

    func testIsLoadingAccessibilityTraits() {
        let button = HABButton(style: .primary)
        button.isLoading = true
        XCTAssertTrue(button.accessibilityTraits.contains(.button))
        XCTAssertTrue(button.accessibilityTraits.contains(.notEnabled))
    }

    func testIsLoadingDisablesInteraction() {
        let button = HABButton(style: .primary)
        button.isLoading = true
        XCTAssertFalse(button.isUserInteractionEnabled)
    }

    func testThemeChangeDoesNotCrash() {
        _ = HABButton(style: .primary, title: "Tap")
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
    }
}
