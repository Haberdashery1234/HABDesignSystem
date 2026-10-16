//
//  HABChipGroupTests.swift
//  HABUIKitTests
//
//  Tests for HABChipGroup.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABChipGroupTests: XCTestCase {
    private let days = ["S", "M", "T", "W", "T", "F", "S"]

    private func chips(in group: HABChipGroup) -> [UIButton] {
        group.descendants(of: UIButton.self)
    }

    private func tap(_ index: Int, in group: HABChipGroup) {
        chips(in: group)[index].simulate(.touchUpInside)
    }

    func testOneChipPerItem() {
        let group = HABChipGroup(items: days)
        XCTAssertEqual(chips(in: group).count, 7)
    }

    func testInitialSelectionIsShownOnChips() {
        let group = HABChipGroup(items: days, selectedIndices: [1, 3])
        let selected = chips(in: group).enumerated().filter { $0.element.isSelected }.map(\.offset)
        XCTAssertEqual(selected, [1, 3])
    }

    func testMultipleSelectionToggles() {
        var received: IndexSet?
        let group = HABChipGroup(items: days, onSelectionChanged: { received = $0 })
        tap(1, in: group)
        tap(3, in: group)
        XCTAssertEqual(group.selectedIndices, [1, 3])
        tap(1, in: group)
        XCTAssertEqual(group.selectedIndices, [3])
        XCTAssertEqual(received, [3])
    }

    func testSingleSelectionReplaces() {
        let group = HABChipGroup(items: ["Day", "Week", "Month"], selectedIndices: [0], selectionMode: .single)
        tap(2, in: group)
        XCTAssertEqual(group.selectedIndices, [2])
    }

    func testSingleModeKeepsOnlyFirstInitialSelection() {
        let group = HABChipGroup(items: ["A", "B", "C"], selectedIndices: [1, 2], selectionMode: .single)
        XCTAssertEqual(group.selectedIndices, [1])
    }

    func testEmptySelectionCanBeDisallowed() {
        let group = HABChipGroup(items: ["A", "B"], selectedIndices: [0])
        group.allowsEmptySelection = false
        tap(0, in: group)
        XCTAssertEqual(group.selectedIndices, [0])
    }

    func testProgrammaticSelectionDoesNotCallBack() {
        var calls = 0
        let group = HABChipGroup(items: days, onSelectionChanged: { _ in calls += 1 })
        group.selectedIndices = [0, 6]
        XCTAssertEqual(calls, 0)
        XCTAssertTrue(chips(in: group)[6].isSelected)
    }

    func testInvalidIndicesAreDropped() {
        let group = HABChipGroup(items: ["A", "B"], selectedIndices: [0, 5])
        XCTAssertEqual(group.selectedIndices, [0])
        group.selectedIndices = [1, 9]
        XCTAssertEqual(group.selectedIndices, [1])
    }

    func testShrinkingItemsDropsSelection() {
        let group = HABChipGroup(items: ["A", "B", "C"], selectedIndices: [2])
        group.items = ["A"]
        XCTAssertTrue(group.selectedIndices.isEmpty)
        XCTAssertEqual(chips(in: group).count, 1)
    }

    func testItemAccessibilityLabels() {
        let group = HABChipGroup(items: ["M", "T"])
        group.itemAccessibilityLabels = ["Monday", "Tuesday"]
        XCTAssertEqual(chips(in: group).map(\.accessibilityLabel), ["Monday", "Tuesday"])
    }

    func testDisablingDisablesChips() {
        let group = HABChipGroup(items: ["A", "B"])
        group.isEnabled = false
        XCTAssertTrue(chips(in: group).allSatisfy { !$0.isEnabled })
    }

    func testFillEquallyLaysOutOneRowOfEqualWidths() {
        let group = HABChipGroup(items: days, layout: .fillEqually)
        group.frame = CGRect(x: 0, y: 0, width: 343, height: 100)
        group.layoutIfNeeded()
        let frames = chips(in: group).map(\.frame)
        XCTAssertEqual(Set(frames.map(\.minY)).count, 1)
        XCTAssertEqual(Set(frames.map { Int($0.width.rounded()) }).count, 1)
    }

    func testWrapLayoutWrapsWhenNarrow() {
        let group = HABChipGroup(items: ["Taken", "Skipped", "Missed", "Snoozed"], layout: .wrap)
        let wide = group.sizeThatFits(CGSize(width: 1000, height: 0)).height
        let narrow = group.sizeThatFits(CGSize(width: 120, height: 0)).height
        XCTAssertGreaterThan(narrow, wide)
    }

    func testIsASemanticGroup() {
        let group = HABChipGroup(items: days)
        XCTAssertEqual(group.accessibilityContainerType, .semanticGroup)
    }
}
