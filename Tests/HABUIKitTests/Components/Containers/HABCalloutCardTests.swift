//
//  HABCalloutCardTests.swift
//  HABUIKitTests
//
//  Tests for HABCalloutCard.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABCalloutCardTests: XCTestCase {
    func testDefaults() {
        let card = HABCalloutCard()
        XCTAssertEqual(card.tone, .primary)
        XCTAssertNil(card.action)
    }

    func testAccessibilityLabelJoinsTitleAndMessage() {
        let card = HABCalloutCard(title: "8:00 AM", message: "Lisinopril")
        XCTAssertTrue(card.isAccessibilityElement)
        XCTAssertEqual(card.accessibilityLabel, "8:00 AM, Lisinopril")
    }

    func testWithoutActionIsStaticText() {
        let card = HABCalloutCard(title: "Note")
        XCTAssertTrue(card.accessibilityTraits.contains(.staticText))
        XCTAssertFalse(card.isUserInteractionEnabled)
        XCTAssertFalse(card.accessibilityActivate())
    }

    func testWithActionIsAButton() {
        var ran = false
        let card = HABCalloutCard(title: "Morning", action: HABAccessibleAction(label: "Open morning doses") { ran = true })
        XCTAssertTrue(card.accessibilityTraits.contains(.button))
        XCTAssertTrue(card.isUserInteractionEnabled)
        XCTAssertEqual(card.accessibilityHint, "Open morning doses")
        XCTAssertTrue(card.accessibilityActivate())
        XCTAssertTrue(ran)
    }

    func testTapRunsAction() {
        var ran = false
        let card = HABCalloutCard(title: "Morning", action: HABAccessibleAction(label: "Morning") { ran = true })
        card.simulate(.touchUpInside)
        XCTAssertTrue(ran)
        XCTAssertNil(card.accessibilityHint, "A hint that repeats the title adds nothing")
    }

    func testEveryToneRenders() {
        let tones: [HABCalloutCard.Tone] = [.primary, .info, .success, .warning, .destructive, .neutral]
        for tone in tones {
            let card = HABCalloutCard(tone: tone, title: "Title")
            XCTAssertNotNil(card.backgroundColor)
        }
    }
}
