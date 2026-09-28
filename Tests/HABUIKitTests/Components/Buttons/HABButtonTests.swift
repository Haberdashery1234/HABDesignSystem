//
//  HABButtonTests.swift
//  HABUIKitTests
//
//  Tests for HABButton.
//

import XCTest
import HABUIKit
import HABFoundation

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

    func testIsLoadingKeepsLabelAndReportsLoadingAsValue() {
        let button = HABButton(style: .primary, title: "Submit")
        button.accessibilityLabel = "Submit form"
        button.isLoading = true
        XCTAssertEqual(button.accessibilityLabel, "Submit form")
        XCTAssertEqual(button.accessibilityValue, "Loading")
        button.isLoading = false
        XCTAssertEqual(button.accessibilityLabel, "Submit form")
        XCTAssertNil(button.accessibilityValue)
        XCTAssertFalse(button.accessibilityTraits.contains(.notEnabled))
    }

    func testIsLoadingKeepsTitleSoWidthDoesNotCollapse() {
        let button = HABButton(style: .primary, title: "Submit")
        button.isLoading = true
        XCTAssertEqual(button.configuration?.title, "Submit")
    }

    func testEndingLoadingDoesNotReenableCallerDisabledInteraction() {
        let button = HABButton(style: .primary, title: "Submit")
        button.isUserInteractionEnabled = false
        button.isLoading = true
        button.isLoading = false
        XCTAssertFalse(button.isUserInteractionEnabled)
    }

    func testEndingLoadingRestoresInteraction() {
        let button = HABButton(style: .primary, title: "Submit")
        button.isLoading = true
        button.isLoading = false
        XCTAssertTrue(button.isUserInteractionEnabled)
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

    // MARK: - Touch target

    func testSmallButtonAcceptsTouchesAcrossAtLeast44Points() {
        let button = HABButton(style: .primary, size: .small, title: "OK")
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        // 7pt above the drawn button is still inside the 44pt touch area.
        XCTAssertTrue(button.point(inside: CGPoint(x: 30, y: -6), with: nil))
        XCTAssertFalse(button.point(inside: CGPoint(x: 30, y: -10), with: nil))
    }

    func testDestructiveUsesOnDestructiveForeground() {
        let button = HABButton(style: .destructive, title: "Delete")
        XCTAssertEqual(button.configuration?.baseForegroundColor, UIColor.habOnDestructive)
    }
}
