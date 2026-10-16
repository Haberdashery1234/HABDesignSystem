//
//  HABFormRowTests.swift
//  HABUIKitTests
//
//  Tests for HABFormRow.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABFormRowTests: XCTestCase {
    func testLabeledRowNamesAControl() {
        let toggle = UISwitch()
        let row = HABFormRow(label: "Reminders", control: toggle)
        XCTAssertEqual(row.label, "Reminders")
        XCTAssertIdentical(row.content, toggle)
        XCTAssertEqual(toggle.accessibilityLabel, "Reminders")
        XCTAssertFalse(row.isAccessibilityElement)
    }

    func testLabeledRowKeepsAControlsOwnLabel() {
        let picker = UIDatePicker()
        picker.accessibilityLabel = "Start date"
        _ = HABFormRow(label: "Starts", control: picker)
        XCTAssertEqual(picker.accessibilityLabel, "Start date")
    }

    func testRelabelingUpdatesTheControl() {
        let toggle = UISwitch()
        let row = HABFormRow(label: "Old", control: toggle)
        row.label = "New"
        XCTAssertEqual(toggle.accessibilityLabel, "New")
    }

    func testLabeledRowNamesAMenuButton() {
        let menu = HABMenuButton(titles: ["Never", "Daily"], selectedIndex: 1)
        _ = HABFormRow(label: "Repeat", control: menu)
        XCTAssertEqual(menu.name, "Repeat")
        XCTAssertEqual(menu.accessibilityLabel, "Repeat")
        XCTAssertEqual(menu.accessibilityValue, "Daily")
    }

    func testReadOnlyValueRowIsOneElement() {
        let value = UILabel()
        value.text = "10 mg"
        let row = HABFormRow(label: "Dose", control: value)
        XCTAssertTrue(row.isAccessibilityElement)
        XCTAssertEqual(row.accessibilityLabel, "Dose")
        XCTAssertEqual(row.accessibilityValue, "10 mg")

        value.text = "20 mg"
        XCTAssertEqual(row.accessibilityValue, "20 mg", "The value follows the label's current text")
    }

    func testFullWidthRowLeavesAccessibilityToItsContent() {
        let toggle = HABToggle(label: "Remind me")
        let row = HABFormRow(content: toggle)
        XCTAssertNil(row.label)
        XCTAssertFalse(row.isAccessibilityElement)
    }

    func testRowIsAtLeast44PointsTall() {
        let row = HABFormRow(label: "A", control: UISwitch())
        let size = row.systemLayoutSizeFitting(
            CGSize(width: 320, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        XCTAssertGreaterThanOrEqual(size.height, 44)
    }
}
