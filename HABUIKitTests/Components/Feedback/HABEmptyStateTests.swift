//
//  HABEmptyStateTests.swift
//  HABUIKitTests
//
//  Tests for HABEmptyState.
//

import XCTest
import HABUIKit

final class HABEmptyStateTests: XCTestCase {
    func testInitWithTitle() {
        let view = HABEmptyState(title: "No Results")
        XCTAssertEqual(view.title, "No Results")
    }

    func testDefaultMessageIsNil() {
        let view = HABEmptyState(title: "Empty")
        XCTAssertNil(view.message)
    }

    func testDefaultIconIsNil() {
        let view = HABEmptyState(title: "Empty")
        XCTAssertNil(view.icon)
    }

    func testDefaultActionIsNil() {
        let view = HABEmptyState(title: "Empty")
        XCTAssertNil(view.action)
    }

    func testInitWithAllProperties() {
        let icon = UIImage(systemName: "tray")
        let action = HABAccessibleAction(label: "Retry") {}
        let view = HABEmptyState(
            title: "Nothing Here",
            message: "Try again later.",
            icon: icon,
            action: action
        )
        XCTAssertEqual(view.title, "Nothing Here")
        XCTAssertEqual(view.message, "Try again later.")
        XCTAssertNotNil(view.icon)
        XCTAssertNotNil(view.action)
    }

    func testTitleMutation() {
        let view = HABEmptyState(title: "Old")
        view.title = "New"
        XCTAssertEqual(view.title, "New")
    }

    func testMessageMutation() {
        let view = HABEmptyState(title: "Empty")
        view.message = "Nothing to see here."
        XCTAssertEqual(view.message, "Nothing to see here.")
    }

    func testClearingMessage() {
        let view = HABEmptyState(title: "Empty", message: "Some text")
        view.message = nil
        XCTAssertNil(view.message)
    }

    func testIconMutation() {
        let view = HABEmptyState(title: "Empty")
        view.icon = UIImage(systemName: "star")
        XCTAssertNotNil(view.icon)
    }

    func testActionMutation() {
        let view = HABEmptyState(title: "Empty")
        view.action = HABAccessibleAction(label: "Reload") {}
        XCTAssertNotNil(view.action)
    }

    func testAccessibilityLabelTitleOnly() {
        let view = HABEmptyState(title: "No Items")
        XCTAssertEqual(view.accessibilityLabel, "No Items")
    }

    func testAccessibilityLabelIncludesMessage() {
        let view = HABEmptyState(title: "No Items", message: "Add one to get started.")
        XCTAssertEqual(view.accessibilityLabel, "No Items. Add one to get started.")
    }
}
