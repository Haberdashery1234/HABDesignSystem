//
//  HABBadgeTests.swift
//  HABUIKitTests
//
//  Tests for HABBadge.
//

import XCTest
import HABUIKit

final class HABBadgeTests: XCTestCase {
    func testZeroIsHiddenOnInit() {
        let badge = HABBadge()
        XCTAssertTrue(badge.isHidden, "Badge should be hidden when number is 0")
    }

    func testNonZeroBecomesVisible() {
        let badge = HABBadge()
        badge.number = 1
        XCTAssertFalse(badge.isHidden)
    }

    func testReturnsToHiddenWhenReset() {
        let badge = HABBadge()
        badge.number = 5
        badge.number = 0
        XCTAssertTrue(badge.isHidden)
    }

    func testHighCountStaysVisible() {
        let badge = HABBadge()
        badge.number = 100
        XCTAssertFalse(badge.isHidden)
    }

    func testAccessibilityLabelReflectsNumber() {
        let badge = HABBadge()
        badge.number = 7
        XCTAssertEqual(badge.accessibilityLabel, "7 notifications")
    }

    func testIsAccessibilityElement() {
        let badge = HABBadge()
        badge.number = 1
        XCTAssertTrue(badge.isAccessibilityElement)
    }
}
