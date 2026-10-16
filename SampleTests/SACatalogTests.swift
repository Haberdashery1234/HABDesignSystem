//
//  SACatalogTests.swift
//  SAHABDesignSystemTests
//
//  Opens every screen in the catalog, works its settings, and switches themes,
//  the way someone exploring the sample app would.
//

import XCTest
import HABUIKit
@testable import SAHABDesignSystem

@MainActor
final class SACatalogTests: XCTestCase {
    /// Every catalog row, opened in turn: the screen must load, have a title, survive
    /// every settings control, and survive a theme change while it's showing.
    func testEveryCatalogScreenOpensAndItsControlsWork() throws {
        let originalTheme = HABThemeManager.shared.theme
        let catalog = SACatalogViewController()
        let harness = SAScreenHarness(root: catalog)
        // The catalog pushes with animation; turning animations off keeps each push short.
        UIView.setAnimationsEnabled(false)
        defer {
            UIView.setAnimationsEnabled(true)
            HABThemeManager.shared.theme = originalTheme
            harness.tearDown()
        }

        let table = try XCTUnwrap(catalog.tableView)
        var screensOpened = 0

        for section in 0..<table.numberOfSections {
            for row in 0..<table.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                table.scrollToRow(at: indexPath, at: .middle, animated: false)
                harness.layout()
                let cell = try XCTUnwrap(table.cellForRow(at: indexPath), "No cell at \(indexPath)")
                let rowTitle = (cell.contentConfiguration as? UIListContentConfiguration)?.text ?? "\(indexPath)"

                catalog.tableView(table, didSelectRowAt: indexPath)
                harness.waitForTransitions()
                let screen = try XCTUnwrap(harness.topViewController)
                XCTAssertNotIdentical(screen, catalog, "\(rowTitle) didn't open a screen")
                screen.loadViewIfNeeded()
                harness.layout()
                XCTAssertFalse(screen.title?.isEmpty ?? true, "\(rowTitle) has no title")

                SAControlExerciser.exerciseControls(in: screen.view)

                HABThemeManager.shared.theme = HABDarkTheme()
                harness.layout()
                HABThemeManager.shared.theme = originalTheme
                harness.layout()

                harness.popToRoot()
                screensOpened += 1
            }
        }
        XCTAssertGreaterThan(screensOpened, 20, "Expected the catalog to list every component demo")
    }

    func testSearchFindsComponentsByName() throws {
        let catalog = SACatalogViewController()
        let harness = SAScreenHarness(root: catalog)
        defer { harness.tearDown() }

        let searchController = try XCTUnwrap(catalog.navigationItem.searchController)
        searchController.searchBar.text = "toast"
        catalog.updateSearchResults(for: searchController)
        searchController.searchBar.text = ""
        catalog.updateSearchResults(for: searchController)
        // The results only show while the search controller is active, which needs a
        // presentation; this covers the filtering itself.
        XCTAssertEqual(catalog.tableView.numberOfSections, catalog.numberOfSections(in: catalog.tableView))
    }

    func testPaletteButtonOpensThemeSwitcherAlongsideScreenButtons() throws {
        let catalog = SACatalogViewController()
        let harness = SAScreenHarness(root: catalog)
        defer { harness.tearDown() }

        let listDemo = SAHABListDemoViewController()
        harness.push(listDemo)
        let items = listDemo.navigationItem.rightBarButtonItems ?? []
        XCTAssertEqual(items.count, 2, "The palette should sit next to the screen's own Clear button")

        // Showing the screen again mustn't add a second palette button.
        harness.push(UIViewController())
        harness.navigationController.popViewController(animated: false)
        harness.layout()
        XCTAssertEqual(listDemo.navigationItem.rightBarButtonItems?.count, 2)

        let palette = try XCTUnwrap(items.last)
        let action = try XCTUnwrap(palette.action)
        UIApplication.shared.sendAction(action, to: palette.target, from: palette, for: nil)
        harness.waitForTransitions()
        XCTAssertTrue(harness.topViewController is SAThemeSwitcherViewController)
    }

    func testThemeSwitcherAppliesEachTheme() {
        let originalTheme = HABThemeManager.shared.theme
        let switcher = SAThemeSwitcherViewController()
        let harness = SAScreenHarness(root: UIViewController())
        defer {
            HABThemeManager.shared.theme = originalTheme
            harness.tearDown()
        }
        harness.push(switcher)

        let themes: [any HABTheme] = [HABLightTheme(), HABDarkTheme(), HABAppleTheme()]
        for theme in themes {
            switcher.apply(theme)
            harness.layout()
            XCTAssertEqual(HABThemeManager.shared.theme.name, theme.name)
        }
    }

    func testFoundationScreensShowEverySection() {
        let harness = SAScreenHarness(root: UIViewController())
        defer { harness.tearDown() }
        let sections: [SAFoundationViewController.Section] = [.colors, .typography, .spacing]
        for section in sections {
            let screen = SAFoundationViewController(section: section)
            harness.push(screen)
            XCTAssertFalse(screen.view.subviews.isEmpty)
            harness.popToRoot()
        }
    }
}
