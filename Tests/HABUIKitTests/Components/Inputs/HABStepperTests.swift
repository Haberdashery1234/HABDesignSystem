//
//  HABStepperTests.swift
//  HABUIKitTests
//
//  Tests for HABStepper.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABStepperTests: XCTestCase {
    func testDefaults() {
        let stepper = HABStepper()
        XCTAssertEqual(stepper.value, 0)
        XCTAssertEqual(stepper.minimumValue, 0)
        XCTAssertEqual(stepper.maximumValue, 100)
        XCTAssertEqual(stepper.stepValue, 1)
        XCTAssertFalse(stepper.wraps)
    }

    func testInitialValueIsClamped() {
        XCTAssertEqual(HABStepper(value: 50, minimumValue: 1, maximumValue: 10).value, 10)
        XCTAssertEqual(HABStepper(value: -5, minimumValue: 1, maximumValue: 10).value, 1)
    }

    func testSettingValueClampsAndDoesNotCallBack() {
        var calls = 0
        let stepper = HABStepper(maximumValue: 5, onValueChanged: { _ in calls += 1 })
        stepper.value = 9
        XCTAssertEqual(stepper.value, 5)
        XCTAssertEqual(calls, 0)
    }

    func testNarrowingTheRangeClampsTheValue() {
        let stepper = HABStepper(value: 8, maximumValue: 10)
        stepper.maximumValue = 4
        XCTAssertEqual(stepper.value, 4)
    }

    func testIgnoresNonPositiveStep() {
        let stepper = HABStepper(stepValue: 0)
        XCTAssertEqual(stepper.stepValue, 1)
        stepper.stepValue = 2
        stepper.stepValue = -1
        XCTAssertEqual(stepper.stepValue, 2)
    }

    func testAccessibilityIncrementAndDecrement() {
        var received: [Double] = []
        let stepper = HABStepper(value: 2, minimumValue: 1, maximumValue: 3, onValueChanged: { received.append($0) })
        stepper.accessibilityIncrement()
        stepper.accessibilityIncrement() // already at max
        stepper.accessibilityDecrement()
        XCTAssertEqual(received, [3, 2])
        XCTAssertEqual(stepper.value, 2)
    }

    func testWrapsAroundWhenEnabled() {
        let stepper = HABStepper(value: 3, minimumValue: 1, maximumValue: 3)
        stepper.wraps = true
        stepper.accessibilityIncrement()
        XCTAssertEqual(stepper.value, 1)
        stepper.accessibilityDecrement()
        XCTAssertEqual(stepper.value, 3)
    }

    func testDisabledStepperDoesNotChange() {
        let stepper = HABStepper(value: 1)
        stepper.isEnabled = false
        stepper.accessibilityIncrement()
        XCTAssertEqual(stepper.value, 1)
        XCTAssertTrue(stepper.accessibilityTraits.contains(.notEnabled))
    }

    func testIsAdjustable() {
        let stepper = HABStepper()
        XCTAssertTrue(stepper.isAccessibilityElement)
        XCTAssertTrue(stepper.accessibilityTraits.contains(.adjustable))
    }

    func testAccessibilityValueUsesFormatter() {
        let stepper = HABStepper(value: 2, labelFormatter: { "Every \(Int($0)) days" })
        XCTAssertEqual(stepper.accessibilityValue, "Every 2 days")
        stepper.accessibilityIncrement()
        XCTAssertEqual(stepper.accessibilityValue, "Every 3 days")
    }

    func testLabelShowsFormattedValue() {
        let stepper = HABStepper(value: 2, labelFormatter: { "Every \(Int($0)) days" })
        let visibleTexts = stepper.descendants(of: UILabel.self).filter { !$0.isHidden }.compactMap(\.text)
        XCTAssertTrue(visibleTexts.contains("Every 2 days"))
    }

    func testNoFormatterHidesLabel() {
        let stepper = HABStepper(value: 2)
        let visibleText = stepper.descendants(of: UILabel.self).filter { !$0.isHidden && !($0.text ?? "").isEmpty }
        XCTAssertTrue(visibleText.isEmpty)
    }

    func testTappingPlusSteps() {
        var received: Double?
        let stepper = HABStepper(value: 1, onValueChanged: { received = $0 })
        let buttons = stepper.descendants(of: UIButton.self)
        XCTAssertEqual(buttons.count, 2)
        // Buttons are [minus, plus]; a touch-down steps once.
        buttons.last?.simulate(.touchDown)
        buttons.last?.simulate(.touchUpInside)
        XCTAssertEqual(received, 2)
    }
}
