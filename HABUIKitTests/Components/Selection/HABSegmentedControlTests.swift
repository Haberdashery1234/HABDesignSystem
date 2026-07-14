//
//  HABSegmentedControlTests.swift
//  HABUIKitTests
//
//  Tests for HABSegmentedControl.
//

import XCTest
import HABUIKit

final class HABSegmentedControlTests: XCTestCase {
    func testInitWithItems() {
        let control = HABSegmentedControl(items: ["A", "B", "C"])
        XCTAssertEqual(control.items, ["A", "B", "C"])
    }

    func testDefaultSelectedIndex() {
        let control = HABSegmentedControl(items: ["A", "B"])
        XCTAssertEqual(control.selectedIndex, 0)
    }

    func testSelectedIndexMutation() {
        let control = HABSegmentedControl(items: ["A", "B", "C"])
        control.selectedIndex = 2
        XCTAssertEqual(control.selectedIndex, 2)
    }

    func testItemsMutation() {
        let control = HABSegmentedControl(items: ["X"])
        control.items = ["One", "Two", "Three"]
        XCTAssertEqual(control.items, ["One", "Two", "Three"])
    }

    func testOnValueChangedFires() {
        var received: Int?
        let control = HABSegmentedControl(items: ["A", "B"], onValueChanged: { received = $0 })
        control.onValueChanged?(1)
        XCTAssertEqual(received, 1)
    }

    // MARK: - Additional coverage

    func testInitWithNonZeroSelectedIndex() {
        let control = HABSegmentedControl(items: ["A", "B", "C"], selectedIndex: 2)
        XCTAssertEqual(control.selectedIndex, 2)
    }

    func testInitWithEmptyItems() {
        let control = HABSegmentedControl(items: [])
        XCTAssertEqual(control.items, [])
    }

    func testThemeChangeDoesNotCrash() {
        _ = HABSegmentedControl(items: ["X", "Y"])
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
    }
}
