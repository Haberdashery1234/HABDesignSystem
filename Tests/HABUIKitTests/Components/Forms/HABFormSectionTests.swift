//
//  HABFormSectionTests.swift
//  HABUIKitTests
//
//  Tests for HABFormSection.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABFormSectionTests: XCTestCase {
    private func makeRow(_ text: String) -> HABFormRow {
        let label = UILabel()
        label.text = text
        return HABFormRow(label: text, control: label)
    }

    /// Dividers whose container is showing.
    private func visibleDividerCount(in section: HABFormSection) -> Int {
        section.descendants(of: HABDivider.self).filter { !($0.superview?.isHidden ?? true) }.count
    }

    private func card(in section: HABFormSection) -> HABCard? {
        section.descendants(of: HABCard.self).first
    }

    func testRowsAreKeptInOrder() {
        let rows = [makeRow("A"), makeRow("B"), makeRow("C")]
        let section = HABFormSection(rows: rows)
        XCTAssertEqual(section.rows.count, 3)
        XCTAssertIdentical(section.rows[1], rows[1])
    }

    func testDividersSitBetweenRowsOnly() {
        let section = HABFormSection(rows: [makeRow("A"), makeRow("B"), makeRow("C")])
        XCTAssertEqual(visibleDividerCount(in: section), 2)
    }

    func testSingleRowHasNoDivider() {
        let section = HABFormSection(rows: [makeRow("A")])
        XCTAssertEqual(visibleDividerCount(in: section), 0)
    }

    func testDividersFollowHiddenRows() {
        let rows = [makeRow("A"), makeRow("B"), makeRow("C")]
        let section = HABFormSection(rows: rows)

        rows[0].isHidden = true
        section.updateDividers()
        XCTAssertEqual(visibleDividerCount(in: section), 1, "B is now first, so only C gets a divider")

        rows[1].isHidden = true
        section.updateDividers()
        XCTAssertEqual(visibleDividerCount(in: section), 0)
    }

    func testCardHidesWhenEveryRowIsHidden() {
        let row = makeRow("A")
        let section = HABFormSection(rows: [row])
        row.isHidden = true
        section.updateDividers()
        XCTAssertTrue(card(in: section)?.isHidden ?? false)
        row.isHidden = false
        section.updateDividers()
        XCTAssertFalse(card(in: section)?.isHidden ?? true)
    }

    func testInsertAndRemoveRows() {
        let first = makeRow("A")
        let inserted = makeRow("B")
        let section = HABFormSection(rows: [first])
        section.insertRow(inserted, at: 0)
        XCTAssertIdentical(section.rows.first, inserted)
        XCTAssertEqual(visibleDividerCount(in: section), 1)

        section.removeRow(inserted)
        XCTAssertEqual(section.rows.count, 1)
        XCTAssertNil(inserted.superview)
        XCTAssertEqual(visibleDividerCount(in: section), 0)
    }

    func testAddingTheSameRowTwiceMovesIt() {
        let row = makeRow("A")
        let section = HABFormSection(rows: [row, makeRow("B")])
        section.addRow(row)
        XCTAssertEqual(section.rows.count, 2)
        XCTAssertIdentical(section.rows.last, row)
    }

    func testHeaderAndFooterVisibility() {
        let section = HABFormSection(header: "Schedule")
        let titleViews = section.descendants(of: HABSectionTitleView.self)
        let header = titleViews.first { $0.kind == .header }
        let footer = titleViews.first { $0.kind == .footer }
        XCTAssertEqual(header?.isHidden, false)
        XCTAssertEqual(footer?.isHidden, true)

        section.footer = "Uses your time zone."
        XCTAssertEqual(footer?.isHidden, false)
        XCTAssertEqual(footer?.text, "Uses your time zone.")
    }

    func testHeaderDetail() {
        let section = HABFormSection(header: "Today", headerDetail: "3 of 4 taken")
        let header = section.descendants(of: HABSectionTitleView.self).first { $0.kind == .header }
        XCTAssertEqual(header?.accessibilityLabel, "Today, 3 of 4 taken")
    }
}
