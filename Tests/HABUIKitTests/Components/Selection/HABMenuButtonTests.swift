//
//  HABMenuButtonTests.swift
//  HABUIKitTests
//
//  Tests for HABMenuButton.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABMenuButtonTests: XCTestCase {
    private let titles = ["Never", "Daily", "Weekly"]

    func testShowsMenuAsPrimaryAction() {
        let button = HABMenuButton(titles: titles)
        XCTAssertTrue(button.showsMenuAsPrimaryAction)
        XCTAssertEqual(button.menu?.children.count, 3)
    }

    func testVoiceOverReadsNameThenValue() {
        let button = HABMenuButton(name: "Repeat", titles: titles, selectedIndex: 1)
        XCTAssertEqual(button.accessibilityLabel, "Repeat")
        XCTAssertEqual(button.accessibilityValue, "Daily")
    }

    func testSelectedOptionIsCheckedInMenu() {
        let button = HABMenuButton(titles: titles, selectedIndex: 2)
        let states = button.menu?.children.compactMap { ($0 as? UIAction)?.state }
        XCTAssertEqual(states, [.off, .off, .on])
    }

    func testButtonTitleShowsSelectedValue() {
        let button = HABMenuButton(titles: titles, selectedIndex: 1)
        XCTAssertEqual(button.configuration?.title, "Daily")
        button.selectedIndex = 2
        XCTAssertEqual(button.configuration?.title, "Weekly")
    }

    func testPlaceholderWhenNothingSelected() {
        let button = HABMenuButton(titles: titles, placeholder: "Choose")
        XCTAssertNil(button.selectedIndex)
        XCTAssertEqual(button.configuration?.title, "Choose")
        XCTAssertEqual(button.accessibilityValue, "Choose")
    }

    func testOutOfRangeSelectionIsCleared() {
        let button = HABMenuButton(titles: titles, selectedIndex: 9)
        XCTAssertNil(button.selectedIndex)
        button.selectedIndex = -1
        XCTAssertNil(button.selectedIndex)
    }

    func testShrinkingOptionsClearsSelection() {
        let button = HABMenuButton(titles: titles, selectedIndex: 2)
        button.options = [.init("Only")]
        XCTAssertNil(button.selectedIndex)
        XCTAssertEqual(button.menu?.children.count, 1)
    }

    func testProgrammaticSelectionDoesNotCallBack() {
        var calls = 0
        let button = HABMenuButton(titles: titles) { _ in calls += 1 }
        button.selectedIndex = 1
        XCTAssertEqual(calls, 0)
        XCTAssertEqual(button.selectedOption?.title, "Daily")
    }

    func testNameUpdatesAccessibilityLabel() {
        let button = HABMenuButton(titles: titles)
        button.name = "Alert"
        XCTAssertEqual(button.accessibilityLabel, "Alert")
    }

    func testTouchAreaIsAtLeast44Points() {
        let button = HABMenuButton(titles: titles)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
        XCTAssertTrue(button.point(inside: CGPoint(x: 30, y: -8), with: nil))
    }
}
