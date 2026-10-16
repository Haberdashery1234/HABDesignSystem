//
//  SAHABListDemoTests.swift
//  SAHABDesignSystemTests
//
//  The list demo: every row, header and footer, selection, swipe actions, and the
//  empty state.
//

import XCTest
import HABUIKit
@testable import SAHABDesignSystem

@MainActor
final class SAHABListDemoTests: XCTestCase {
    private func makeDemo() -> (SAHABListDemoViewController, SAScreenHarness) {
        let demo = SAHABListDemoViewController()
        let harness = SAScreenHarness(root: UIViewController())
        harness.push(demo)
        return (demo, harness)
    }

    private func allIndexPaths(in table: UITableView) -> [IndexPath] {
        (0..<table.numberOfSections).flatMap { section in
            (0..<table.numberOfRows(inSection: section)).map { IndexPath(row: $0, section: section) }
        }
    }

    func testEveryRowIsAListCell() throws {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }
        let table = demo.tableView!

        for indexPath in allIndexPaths(in: table) {
            table.scrollToRow(at: indexPath, at: .middle, animated: false)
            harness.layout()
            let cell = try XCTUnwrap(table.cellForRow(at: indexPath) as? HABListCell, "Row \(indexPath)")
            XCTAssertFalse(cell.title?.isEmpty ?? true, "Row \(indexPath) has no title")
        }
    }

    func testHeadersAndFooters() {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }
        let table = demo.tableView!

        for section in 0..<table.numberOfSections {
            let header = demo.tableView(table, viewForHeaderInSection: section) as? HABSectionHeaderFooterView
            XCTAssertFalse(header?.titleView.text?.isEmpty ?? true, "Section \(section) has no header")
            _ = demo.tableView(table, viewForFooterInSection: section)
        }
        let today = demo.tableView(table, viewForHeaderInSection: 0) as? HABSectionHeaderFooterView
        XCTAssertEqual(today?.titleView.detail, "2 of 3 on time")
    }

    func testSelectingRows() {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }
        let table = demo.tableView!

        for indexPath in allIndexPaths(in: table) {
            demo.tableView(table, didSelectRowAt: indexPath)
            harness.layout()
        }
        // Frequency rows are a single choice: the last one tapped has the checkmark.
        let frequencySection = 1
        let lastChoice = IndexPath(row: 2, section: frequencySection)
        table.scrollToRow(at: lastChoice, at: .middle, animated: false)
        harness.layout()
        let cell = table.cellForRow(at: lastChoice) as? HABListCell
        XCTAssertTrue(cell?.accessibilityTraits.contains(.selected) ?? false)
    }

    func testSwipeActions() throws {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }
        let table = demo.tableView!
        let first = IndexPath(row: 0, section: 0)

        let leading = try XCTUnwrap(demo.tableView(table, leadingSwipeActionsConfigurationForRowAt: first))
        XCTAssertEqual(leading.actions.map(\.title), ["Taken"])

        let trailing = try XCTUnwrap(demo.tableView(table, trailingSwipeActionsConfigurationForRowAt: first))
        XCTAssertEqual(trailing.actions.map(\.title), ["Delete", "Skip", "Edit"])
        XCTAssertNil(demo.tableView(table, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 2)))

        // Run every handler; Delete removes the row.
        let rowsBefore = table.numberOfRows(inSection: 0)
        for action in leading.actions + trailing.actions {
            var completed: Bool?
            action.handler(action, table) { completed = $0 }
            XCTAssertTrue(completed ?? false, "\(action.title ?? "") didn't report success")
        }
        harness.layout()
        XCTAssertEqual(table.numberOfRows(inSection: 0), rowsBefore - 1)
    }

    func testClearShowsEmptyStateAndRestoreHidesIt() {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }

        demo.clearEverything()
        XCTAssertTrue(demo.isEmptyStateVisible)
        XCTAssertEqual(demo.tableView.numberOfSections, 0)

        demo.restoreMedications()
        XCTAssertFalse(demo.isEmptyStateVisible)
        XCTAssertEqual(demo.tableView.numberOfRows(inSection: 0), 3)
    }

    func testFloatingActionButtonRestoresMedications() throws {
        let (demo, harness) = makeDemo()
        defer { harness.tearDown() }

        demo.clearEverything()
        let button = try XCTUnwrap(demo.floatingActionButton)
        button.sendActions(for: .touchUpInside)
        XCTAssertFalse(demo.isEmptyStateVisible)
    }
}
