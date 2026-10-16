//
//  HABTabBarControllerTests.swift
//  HABUIKitTests
//
//  Tests for HABTab and HABTabBarController.
//

import XCTest
import UIKit
import HABUIKit
import HABFoundation

final class HABTabBarControllerTests: XCTestCase {
    override func tearDown() {
        HABThemeManager.shared.theme = HABDefaultTheme()
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeTab(
        _ title: String,
        embedded: Bool = true,
        viewController: UIViewController = UIViewController()
    ) -> HABTab {
        HABTab(
            title: title,
            image: UIImage(systemName: "circle"),
            selectedImage: UIImage(systemName: "circle.fill"),
            viewController: viewController,
            embedsInNavigationController: embedded
        )
    }

    private func makeController(tabCount: Int = 3, selectedIndex: Int = 0) -> HABTabBarController {
        let tabs = (0..<tabCount).map { makeTab("Tab \($0)") }
        return HABTabBarController(tabs: tabs, selectedIndex: selectedIndex)
    }

    // MARK: - HABTab

    func testTabDefaults() {
        let tab = HABTab(title: "Home", image: nil, viewController: UIViewController())
        XCTAssertTrue(tab.embedsInNavigationController)
        XCTAssertNil(tab.selectedImage)
        XCTAssertNil(tab.accessibilityIdentifier)
    }

    // MARK: - Init

    func testInitWithNoTabs() {
        let controller = HABTabBarController()
        XCTAssertEqual(controller.viewControllers?.count ?? 0, 0)
    }

    func testInitWithTabsCreatesOneViewControllerPerTab() {
        let controller = makeController(tabCount: 3)
        XCTAssertEqual(controller.viewControllers?.count, 3)
    }

    func testInitSelectsFirstTabByDefault() {
        XCTAssertEqual(makeController().selectedIndex, 0)
    }

    func testInitWithSelectedIndex() {
        XCTAssertEqual(makeController(tabCount: 3, selectedIndex: 2).selectedIndex, 2)
    }

    func testInitClampsSelectedIndexAboveRange() {
        XCTAssertEqual(makeController(tabCount: 3, selectedIndex: 10).selectedIndex, 2)
    }

    func testInitClampsNegativeSelectedIndex() {
        XCTAssertEqual(makeController(tabCount: 3, selectedIndex: -1).selectedIndex, 0)
    }

    // MARK: - Tab Configuration

    func testEmbeddedTabIsWrappedInHABNavigationController() throws {
        let content = UIViewController()
        let controller = HABTabBarController(tabs: [makeTab("Home", embedded: true, viewController: content)])

        let navigation = try XCTUnwrap(controller.viewControllers?.first as? HABNavigationController)
        XCTAssertIdentical(navigation.viewControllers.first, content)
    }

    func testNonEmbeddedTabIsUsedDirectly() {
        let content = UIViewController()
        let controller = HABTabBarController(tabs: [makeTab("Home", embedded: false, viewController: content)])

        XCTAssertIdentical(controller.viewControllers?.first, content)
    }

    func testTabBarItemUsesTabTitleAndImages() throws {
        let image = UIImage(systemName: "house")
        let selectedImage = UIImage(systemName: "house.fill")
        let tab = HABTab(title: "Home", image: image, selectedImage: selectedImage, viewController: UIViewController())

        let item = try XCTUnwrap(HABTabBarController(tabs: [tab]).viewControllers?.first?.tabBarItem)
        XCTAssertEqual(item.title, "Home")
        // UITabBarItem stores its own copies of the images, so compare what they draw.
        XCTAssertEqual(item.image?.pngData(), image?.pngData())
        XCTAssertEqual(item.selectedImage?.pngData(), selectedImage?.pngData())
        XCTAssertNotEqual(item.image?.pngData(), item.selectedImage?.pngData())
    }

    func testSelectedImageFallsBackToImage() throws {
        let image = UIImage(systemName: "house")
        let tab = HABTab(title: "Home", image: image, viewController: UIViewController())

        let item = try XCTUnwrap(HABTabBarController(tabs: [tab]).viewControllers?.first?.tabBarItem)
        XCTAssertEqual(item.selectedImage?.pngData(), image?.pngData())
    }

    func testTabBarItemAccessibilityIdentifier() throws {
        let tab = HABTab(title: "Home", image: nil, viewController: UIViewController(), accessibilityIdentifier: "tab.home")

        let item = try XCTUnwrap(HABTabBarController(tabs: [tab]).viewControllers?.first?.tabBarItem)
        XCTAssertEqual(item.accessibilityIdentifier, "tab.home")
    }

    func testSetTabsReplacesExistingTabs() {
        let controller = makeController(tabCount: 3)
        controller.setTabs([makeTab("Only")])

        XCTAssertEqual(controller.viewControllers?.count, 1)
        XCTAssertEqual(controller.viewControllers?.first?.tabBarItem.title, "Only")
    }

    func testSetTabsToEmptyRemovesAllTabs() {
        let controller = makeController(tabCount: 2)
        controller.setTabs([])
        XCTAssertEqual(controller.viewControllers?.count ?? 0, 0)
    }

    // MARK: - Badges

    func testSetBadgeCountShowsCount() {
        let controller = makeController()
        controller.setBadgeCount(5, forTabAt: 1)
        XCTAssertEqual(controller.badgeValue(forTabAt: 1), 5.formatted())
    }

    func testSetBadgeCountAtMaximumShowsExactCount() {
        let controller = makeController()
        controller.setBadgeCount(HABTabBarController.maximumBadgeCount, forTabAt: 0)
        XCTAssertEqual(controller.badgeValue(forTabAt: 0), HABTabBarController.maximumBadgeCount.formatted())
    }

    func testSetBadgeCountAboveMaximumIsCapped() {
        let controller = makeController()
        controller.setBadgeCount(HABTabBarController.maximumBadgeCount + 1, forTabAt: 0)
        XCTAssertEqual(controller.badgeValue(forTabAt: 0), "\(HABTabBarController.maximumBadgeCount.formatted())+")
    }

    func testSetBadgeCountZeroClearsBadge() {
        let controller = makeController()
        controller.setBadgeCount(4, forTabAt: 0)
        controller.setBadgeCount(0, forTabAt: 0)
        XCTAssertNil(controller.badgeValue(forTabAt: 0))
    }

    func testSetBadgeCountNegativeClearsBadge() {
        let controller = makeController()
        controller.setBadgeCount(4, forTabAt: 0)
        controller.setBadgeCount(-3, forTabAt: 0)
        XCTAssertNil(controller.badgeValue(forTabAt: 0))
    }

    func testSetBadgeValueText() {
        let controller = makeController()
        controller.setBadgeValue("New", forTabAt: 2)
        XCTAssertEqual(controller.badgeValue(forTabAt: 2), "New")
        XCTAssertEqual(controller.viewControllers?[2].tabBarItem.badgeValue, "New")
    }

    func testSetBadgeValueNilClearsBadge() {
        let controller = makeController()
        controller.setBadgeValue("New", forTabAt: 0)
        controller.setBadgeValue(nil, forTabAt: 0)
        XCTAssertNil(controller.badgeValue(forTabAt: 0))
    }

    func testBadgeOnlyAffectsTargetTab() {
        let controller = makeController(tabCount: 3)
        controller.setBadgeCount(2, forTabAt: 1)
        XCTAssertNil(controller.badgeValue(forTabAt: 0))
        XCTAssertNil(controller.badgeValue(forTabAt: 2))
    }

    func testBadgeOutOfRangeIndexIsIgnored() {
        let controller = makeController(tabCount: 2)
        controller.setBadgeCount(3, forTabAt: 5)
        controller.setBadgeValue("X", forTabAt: -1)
        XCTAssertNil(controller.badgeValue(forTabAt: 5))
        XCTAssertNil(controller.badgeValue(forTabAt: -1))
        XCTAssertNil(controller.badgeValue(forTabAt: 0))
        XCTAssertNil(controller.badgeValue(forTabAt: 1))
    }

    func testBadgeWithNoTabsIsIgnored() {
        let controller = HABTabBarController()
        controller.setBadgeCount(1, forTabAt: 0)
        XCTAssertNil(controller.badgeValue(forTabAt: 0))
    }

    // MARK: - Selection

    func testOnTabSelectedFiresWithTappedIndex() throws {
        let controller = makeController(tabCount: 3)
        controller.loadViewIfNeeded()
        var received: Int?
        controller.onTabSelected = { received = $0 }

        let item = try XCTUnwrap(controller.viewControllers?[2].tabBarItem)
        controller.tabBar(controller.tabBar, didSelect: item)

        XCTAssertEqual(received, 2)
    }

    func testOnTabSelectedFiresOnReselect() throws {
        let controller = makeController(tabCount: 3, selectedIndex: 1)
        controller.loadViewIfNeeded()
        var calls: [Int] = []
        controller.onTabSelected = { calls.append($0) }

        let item = try XCTUnwrap(controller.viewControllers?[1].tabBarItem)
        controller.tabBar(controller.tabBar, didSelect: item)

        XCTAssertEqual(calls, [1])
    }

    func testOnTabSelectedNotCalledForProgrammaticSelection() {
        let controller = makeController(tabCount: 3)
        var called = false
        controller.onTabSelected = { _ in called = true }

        controller.selectedIndex = 2

        XCTAssertFalse(called)
    }

    // MARK: - Appearance

    func testAppearanceAppliedOnLoad() {
        let controller = makeController()
        controller.loadViewIfNeeded()
        let appearance = controller.tabBar.standardAppearance

        XCTAssertIdentical(appearance.backgroundColor, UIColor.habBackground)
        XCTAssertIdentical(appearance.shadowColor, UIColor.habBorderSubtle)
        XCTAssertIdentical(controller.tabBar.tintColor, UIColor.habPrimary)
        XCTAssertIdentical(controller.tabBar.unselectedItemTintColor, UIColor.habForegroundSecondary)
    }

    func testScrollEdgeAppearanceMatchesStandard() throws {
        let controller = makeController()
        controller.loadViewIfNeeded()

        let scrollEdge = try XCTUnwrap(controller.tabBar.scrollEdgeAppearance)
        XCTAssertIdentical(scrollEdge.backgroundColor, controller.tabBar.standardAppearance.backgroundColor)
        XCTAssertIdentical(
            scrollEdge.stackedLayoutAppearance.selected.iconColor,
            controller.tabBar.standardAppearance.stackedLayoutAppearance.selected.iconColor
        )
    }

    func testItemColorsMeetDesignTokens() {
        let controller = makeController()
        controller.loadViewIfNeeded()
        let item = controller.tabBar.standardAppearance.stackedLayoutAppearance

        XCTAssertIdentical(item.normal.iconColor, UIColor.habForegroundSecondary)
        XCTAssertIdentical(item.normal.titleTextAttributes[.foregroundColor] as? UIColor, UIColor.habForegroundSecondary)
        XCTAssertIdentical(item.selected.iconColor, UIColor.habPrimary)
        XCTAssertIdentical(item.selected.titleTextAttributes[.foregroundColor] as? UIColor, UIColor.habPrimary)
    }

    func testItemTitleFontIsCaption1() {
        let controller = makeController()
        controller.loadViewIfNeeded()
        let item = controller.tabBar.standardAppearance.stackedLayoutAppearance

        XCTAssertEqual(item.normal.titleTextAttributes[.font] as? UIFont, UIFont.habCaption1)
        XCTAssertEqual(item.selected.titleTextAttributes[.font] as? UIFont, UIFont.habCaption1)
    }

    func testBadgeColorsUseDestructiveTokens() {
        let controller = makeController()
        controller.loadViewIfNeeded()
        let item = controller.tabBar.standardAppearance.stackedLayoutAppearance

        for state in [item.normal, item.selected] {
            XCTAssertIdentical(state.badgeBackgroundColor, UIColor.habDestructive)
            XCTAssertIdentical(state.badgeTextAttributes[.foregroundColor] as? UIColor, UIColor.habOnDestructive)
        }
    }

    func testAllLayoutsShareTheSameItemAppearance() {
        let controller = makeController()
        controller.loadViewIfNeeded()
        let appearance = controller.tabBar.standardAppearance

        for layout in [appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            XCTAssertIdentical(layout.selected.iconColor, UIColor.habPrimary)
            XCTAssertIdentical(layout.normal.iconColor, UIColor.habForegroundSecondary)
        }
    }

    func testAppearanceAppliesWhenViewControllersSetDirectly() {
        let controller = HABTabBarController()
        controller.viewControllers = [UIViewController(), UIViewController()]
        controller.loadViewIfNeeded()

        XCTAssertIdentical(controller.tabBar.standardAppearance.stackedLayoutAppearance.selected.iconColor, UIColor.habPrimary)
    }

    // MARK: - Theme

    func testThemeChangeReappliesTitleFont() {
        let controller = makeController()
        controller.loadViewIfNeeded()

        HABThemeManager.shared.theme = LargeCaptionTheme()

        let item = controller.tabBar.standardAppearance.stackedLayoutAppearance
        let font = item.normal.titleTextAttributes[.font] as? UIFont
        XCTAssertEqual(font?.pointSize, LargeCaptionTheme.captionFont.pointSize)
    }

    func testThemeDidChangeCalledOnceOnLoad() {
        // UITabBarController may load its view during init (it does on iOS 26), so
        // only check that the hook has run exactly once by the time the view exists.
        let controller = ThemeObservingTabBarController()
        controller.loadViewIfNeeded()

        XCTAssertEqual(controller.themeChangeCount, 1)
    }

    func testThemeDidChangeCalledOnThemeChange() {
        let controller = ThemeObservingTabBarController()
        controller.loadViewIfNeeded()

        HABThemeManager.shared.theme = HABDarkTheme()

        XCTAssertEqual(controller.themeChangeCount, 2)
    }

    func testThemeChangeBeforeLoadDoesNotCrash() {
        let controller = makeController()
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
        controller.loadViewIfNeeded()
        XCTAssertIdentical(controller.tabBar.tintColor, UIColor.habPrimary)
    }
}

// MARK: - Test Doubles

/// Counts calls to the subclass hook.
private final class ThemeObservingTabBarController: HABTabBarController {
    private(set) var themeChangeCount = 0

    override func themeDidChange() {
        super.themeDidChange()
        themeChangeCount += 1
    }
}

/// A theme whose caption font is easy to tell apart from the default.
private struct LargeCaptionTheme: HABTheme {
    static let captionFont = UIFont.systemFont(ofSize: 30)

    let name = "LargeCaption"
    let colors = HABColorTokens()
    let typography: HABTypographyTokens = {
        var tokens = HABTypographyTokens()
        tokens.caption1 = HABTextStyle(font: LargeCaptionTheme.captionFont)
        return tokens
    }()
}
