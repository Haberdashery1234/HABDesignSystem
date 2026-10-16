//
//  HABBaseTableViewControllerTests.swift
//  HABUIKitTests
//
//  Tests for HABBaseTableViewController's empty state and floating action button.
//

import XCTest
import HABUIKit
import HABFoundation

private final class RowCountTableViewController: HABBaseTableViewController {
    var rowCount = 0

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

final class HABBaseTableViewControllerTests: XCTestCase {
    private func makeController(rows: Int = 0) -> RowCountTableViewController {
        let controller = RowCountTableViewController(style: .plain)
        controller.rowCount = rows
        controller.emptyState = HABEmptyState(title: "Nothing here")
        controller.loadViewIfNeeded()
        return controller
    }

    // MARK: - Empty state

    func testEmptyStateStartsHidden() {
        let controller = makeController()
        XCTAssertFalse(controller.isEmptyStateVisible)
        XCTAssertNotNil(controller.tableView.backgroundView)
        XCTAssertTrue(controller.emptyState?.isDescendant(of: controller.tableView.backgroundView!) ?? false)
    }

    func testUpdateShowsEmptyStateWithNoRows() {
        let controller = makeController(rows: 0)
        controller.updateEmptyStateVisibility()
        XCTAssertTrue(controller.isEmptyStateVisible)
        XCTAssertFalse(controller.tableView.backgroundView?.isHidden ?? true)
    }

    func testUpdateHidesEmptyStateWithRows() {
        let controller = makeController(rows: 0)
        controller.updateEmptyStateVisibility()
        controller.rowCount = 3
        controller.tableView.reloadData()
        controller.updateEmptyStateVisibility()
        XCTAssertFalse(controller.isEmptyStateVisible)
        XCTAssertTrue(controller.tableView.backgroundView?.isHidden ?? false)
    }

    func testSeparatorsHideWhileEmptyAndComeBack() {
        let controller = makeController()
        controller.tableView.separatorStyle = .singleLine
        controller.setEmptyStateVisible(true)
        XCTAssertEqual(controller.tableView.separatorStyle, UITableViewCell.SeparatorStyle.none)
        controller.setEmptyStateVisible(false)
        XCTAssertEqual(controller.tableView.separatorStyle, .singleLine)
    }

    func testNoEmptyStateMeansNeverVisible() {
        let controller = RowCountTableViewController(style: .plain)
        controller.loadViewIfNeeded()
        controller.setEmptyStateVisible(true)
        XCTAssertFalse(controller.isEmptyStateVisible)
    }

    func testRemovingEmptyStateWhileVisibleRestoresSeparators() {
        let controller = makeController()
        controller.tableView.separatorStyle = .singleLine
        controller.setEmptyStateVisible(true)
        controller.emptyState = nil
        XCTAssertFalse(controller.isEmptyStateVisible)
        XCTAssertEqual(controller.tableView.separatorStyle, .singleLine)
    }

    func testEmptyStateSetBeforeViewLoadsIsInstalled() {
        let controller = RowCountTableViewController(style: .plain)
        let emptyState = HABEmptyState(title: "Empty")
        controller.emptyState = emptyState
        XCTAssertFalse(controller.isViewLoaded, "Setting the empty state shouldn't load the view")
        controller.loadViewIfNeeded()
        XCTAssertNotNil(emptyState.superview)
    }

    // MARK: - Floating action button

    func testFloatingActionButtonIsInstalledInTheTable() {
        let controller = makeController()
        let button = HABFloatingActionButton(
            icon: UIImage(systemName: "plus"),
            action: HABAccessibleAction(label: "Add") {}
        )
        let insetBefore = controller.tableView.contentInset.bottom
        controller.floatingActionButton = button
        XCTAssertIdentical(button.superview, controller.tableView)
        XCTAssertGreaterThan(controller.tableView.contentInset.bottom, insetBefore)

        controller.floatingActionButton = nil
        XCTAssertNil(button.superview)
        XCTAssertEqual(controller.tableView.contentInset.bottom, insetBefore)
    }
}
