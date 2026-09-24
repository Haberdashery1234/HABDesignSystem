//
//  HABTagTests.swift
//  HABUIKitTests
//
//  Tests for HABTag.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABTagTests: XCTestCase {
    func testInitWithDefaults() {
        let tag = HABTag()
        XCTAssertEqual(tag.label, "")
        XCTAssertEqual(tag.style, .filled)
        XCTAssertEqual(tag.color, .primary)
        XCTAssertFalse(tag.showsLeadingDot)
        XCTAssertNil(tag.dismissAction)
    }

    func testInitWithValues() {
        let tag = HABTag(label: "Beta", style: .outlined, color: .success)
        XCTAssertEqual(tag.label, "Beta")
        XCTAssertEqual(tag.style, .outlined)
        XCTAssertEqual(tag.color, .success)
    }

    func testLabelMutation() {
        let tag = HABTag(label: "Old")
        tag.label = "New"
        XCTAssertEqual(tag.label, "New")
    }

    func testStyleMutation() {
        let tag = HABTag()
        tag.style = .subtle
        XCTAssertEqual(tag.style, .subtle)
    }

    func testColorMutation() {
        let tag = HABTag()
        tag.color = .destructive
        XCTAssertEqual(tag.color, .destructive)
    }

    func testShowsLeadingDotMutation() {
        let tag = HABTag()
        tag.showsLeadingDot = true
        XCTAssertTrue(tag.showsLeadingDot)
    }

    func testDismissActionMutation() {
        let tag = HABTag()
        XCTAssertNil(tag.dismissAction)
        tag.dismissAction = HABAccessibleAction(label: "Remove") {}
        XCTAssertNotNil(tag.dismissAction)
    }

    func testAccessibilityTraitsWithoutDismiss() {
        let tag = HABTag(label: "Status")
        XCTAssertTrue(tag.accessibilityTraits.contains(.staticText))
        XCTAssertFalse(tag.accessibilityTraits.contains(.button))
    }

    func testDismissIsExposedAsVoiceOverCustomAction() {
        var dismissed = false
        let tag = HABTag(label: "Status")
        tag.dismissAction = HABAccessibleAction(label: "Remove") { dismissed = true }

        let actions = tag.accessibilityCustomActions ?? []
        XCTAssertEqual(actions.map(\.name), ["Remove"])
        _ = actions.first?.actionHandler?(actions[0])
        XCTAssertTrue(dismissed)
    }

    func testClearingDismissRemovesCustomAction() {
        let tag = HABTag(label: "Status")
        tag.dismissAction = HABAccessibleAction(label: "Remove") {}
        tag.dismissAction = nil
        XCTAssertTrue(tag.accessibilityCustomActions?.isEmpty ?? true)
    }

    func testSubtleBackgroundIsLighterThanFilled() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        let filled = HABTag(label: "A", style: .filled, color: .success)
        let subtle = HABTag(label: "A", style: .subtle, color: .success)
        let filledAlpha = filled.backgroundColor?.resolvedColor(with: traits).cgColor.alpha ?? 0
        let subtleAlpha = subtle.backgroundColor?.resolvedColor(with: traits).cgColor.alpha ?? 0
        XCTAssertGreaterThan(filledAlpha, 0)
        XCTAssertEqual(subtleAlpha, filledAlpha * 0.5, accuracy: 0.001)
    }
}
