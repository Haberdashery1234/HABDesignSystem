//
//  SAHABFormDemoTests.swift
//  SAHABDesignSystemTests
//
//  The form demo: rows that show and hide with the Repeat menu, and the name field
//  updating its section footer as you type.
//

import XCTest
import HABUIKit
@testable import SAHABDesignSystem

@MainActor
final class SAHABFormDemoTests: XCTestCase {
    private func makeDemo() -> (SAHABFormDemoViewController, SAScreenHarness) {
        let demo = SAHABFormDemoViewController()
        let harness = SAScreenHarness(root: UIViewController())
        harness.push(demo)
        return (demo, harness)
    }

    func testRepeatMenuShowsTheMatchingRow() throws {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }

        let repeatButton = try XCTUnwrap(
            demo.view.saDescendants(of: HABMenuButton.self).first { $0.name == "Repeat" }
        )
        let chipsRow = try XCTUnwrap(demo.view.saDescendants(of: HABChipGroup.self).first?.superview?.superview)
        let stepperRow = try XCTUnwrap(demo.view.saDescendants(of: HABStepper.self).first?.superview?.superview)

        // "On certain days" (the initial choice) shows the weekday chips.
        XCTAssertFalse(chipsRow.isHidden)
        XCTAssertTrue(stepperRow.isHidden)

        repeatButton.onSelectionChanged?(1) // Every few days
        XCTAssertTrue(chipsRow.isHidden)
        XCTAssertFalse(stepperRow.isHidden)

        repeatButton.onSelectionChanged?(0) // Daily
        XCTAssertTrue(chipsRow.isHidden)
        XCTAssertTrue(stepperRow.isHidden)
    }

    func testTypingANameUpdatesTheFooterAndValidates() throws {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }

        let nameField = try XCTUnwrap(demo.view.saDescendants(of: HABTextField.self).first)
        let input = try XCTUnwrap(nameField.saDescendants(of: UITextField.self).first)
        let section = try XCTUnwrap(
            demo.view.saDescendants(of: HABFormSection.self).first { $0.header == "Medication" }
        )

        input.text = "Lisinopril"
        input.sendActions(for: .editingChanged)
        XCTAssertEqual(section.footer, "10 characters")
        XCTAssertNil(nameField.errorText)

        input.text = String(repeating: "x", count: 41)
        input.sendActions(for: .editingChanged)
        XCTAssertNotNil(nameField.errorText)

        input.text = ""
        input.sendActions(for: .editingChanged)
        XCTAssertEqual(section.footer, "Type a name; this footer updates as you type.")
    }

    func testEveryControlWorks() {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }
        SAControlExerciser.exerciseControls(in: demo.view)
        harness.layout()
    }
}
