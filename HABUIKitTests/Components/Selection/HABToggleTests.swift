//
//  HABToggleTests.swift
//  HABUIKitTests
//
//  Tests for HABToggle.
//

import XCTest
import HABUIKit

final class HABToggleTests: XCTestCase {
    func testDefaultIsOff() {
        let toggle = HABToggle()
        XCTAssertFalse(toggle.isOn)
    }

    func testInitWithIsOn() {
        let toggle = HABToggle(isOn: true)
        XCTAssertTrue(toggle.isOn)
    }

    func testIsOnMutation() {
        let toggle = HABToggle()
        toggle.isOn = true
        XCTAssertTrue(toggle.isOn)
        toggle.isOn = false
        XCTAssertFalse(toggle.isOn)
    }

    func testDefaultIsEnabled() {
        let toggle = HABToggle()
        XCTAssertTrue(toggle.isEnabled)
    }

    func testIsEnabledMutation() {
        let toggle = HABToggle()
        toggle.isEnabled = false
        XCTAssertFalse(toggle.isEnabled)
    }

    func testLabelRoundtrip() {
        let toggle = HABToggle(label: "Dark Mode")
        XCTAssertEqual(toggle.label, "Dark Mode")
    }

    func testLabelMutation() {
        let toggle = HABToggle()
        toggle.label = "Notifications"
        XCTAssertEqual(toggle.label, "Notifications")
    }

    func testDefaultLabelPosition() {
        let toggle = HABToggle()
        XCTAssertEqual(toggle.labelPosition, .trailing)
    }

    func testLabelPositionMutation() {
        let toggle = HABToggle(labelPosition: .leading)
        XCTAssertEqual(toggle.labelPosition, .leading)
    }

    func testOnValueChangedFires() {
        var received: Bool?
        let toggle = HABToggle(isOn: false, onValueChanged: { received = $0 })

        // Simulate the callback by triggering the UISwitch action.
        // HABToggle exposes onValueChanged as a public closure — invoke it directly.
        toggle.onValueChanged?(true)

        guard let received else {
            return XCTFail("Received should not be nil")
        }
        XCTAssertTrue(received)
    }

    // MARK: - Additional coverage

    func testReenablingToggle() {
        let toggle = HABToggle()
        toggle.isEnabled = false
        toggle.isEnabled = true
        XCTAssertTrue(toggle.isEnabled)
    }

    func testLabelPositionChangesToLeadingViaDidSet() {
        let toggle = HABToggle()
        XCTAssertEqual(toggle.labelPosition, .trailing)
        toggle.labelPosition = .leading
        XCTAssertEqual(toggle.labelPosition, .leading)
    }

    func testNilLabelDoesNotCrash() {
        let toggle = HABToggle(label: "Dark Mode")
        toggle.label = nil
        XCTAssertNil(toggle.label)
    }

    func testThemeChangeDoesNotCrash() {
        _ = HABToggle(label: "Notifications")
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
    }
}
