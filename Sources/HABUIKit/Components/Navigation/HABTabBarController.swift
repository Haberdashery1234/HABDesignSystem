//
//  HABTabBarController.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

// MARK: - HABTab

/// One tab in an `HABTabBarController`: the screen to show and how its tab bar item looks.
///
/// ```swift
/// let home = HABTab(
///     title: "Home",
///     image: UIImage(systemName: "house"),
///     selectedImage: UIImage(systemName: "house.fill"),
///     viewController: HomeViewController()
/// )
/// ```
public struct HABTab {
    /// Title shown under the tab's icon, and read by VoiceOver.
    public var title: String

    /// Icon for the unselected state.
    public var image: UIImage?

    /// Icon for the selected state. When `nil`, `image` is used for both states.
    public var selectedImage: UIImage?

    /// The screen this tab shows.
    public var viewController: UIViewController

    /// When `true`, `viewController` is wrapped in an `HABNavigationController`,
    /// so it gets a themed navigation bar and can push. Pass `false` if the view
    /// controller is already a navigation controller or doesn't need one.
    public var embedsInNavigationController: Bool

    /// Accessibility identifier for the tab bar item, for UI tests.
    public var accessibilityIdentifier: String?

    public init(
        title: String,
        image: UIImage?,
        selectedImage: UIImage? = nil,
        viewController: UIViewController,
        embedsInNavigationController: Bool = true,
        accessibilityIdentifier: String? = nil
    ) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.viewController = viewController
        self.embedsInNavigationController = embedsInNavigationController
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

// MARK: - HABTabBarController

/// A `UITabBarController` styled with the active HAB theme.
///
/// Build it from `HABTab`s, or assign `viewControllers` directly as with any
/// `UITabBarController` — the theming applies either way.
///
/// ```swift
/// let tabBarController = HABTabBarController(tabs: [
///     HABTab(title: "Home", image: UIImage(systemName: "house"), viewController: HomeViewController()),
///     HABTab(title: "Inbox", image: UIImage(systemName: "tray"), viewController: InboxViewController())
/// ])
/// tabBarController.setBadgeCount(3, forTabAt: 1)
/// tabBarController.onTabSelected = { index in analytics.log(tab: index) }
/// ```
///
/// Colors update automatically when the theme changes. The tab title font and the
/// appearance objects are re-applied on `themeDidChangeNotification`; subclasses can
/// override `themeDidChange()` to re-apply their own theme-dependent values.
open class HABTabBarController: UITabBarController {
    // MARK: - Constants

    /// Badge counts above this are shown as "99+".
    nonisolated public static let maximumBadgeCount = 99

    // MARK: - Public Properties

    /// Called when the user taps a tab, with that tab's index in `viewControllers`.
    /// Also called when the user taps the tab that's already selected (useful for
    /// scroll-to-top). Not called when `selectedIndex` is set in code, or for the
    /// system "More" tab.
    public var onTabSelected: ((Int) -> Void)?

    // MARK: - Init

    /// Creates a tab bar controller showing `tabs`, with the tab at `selectedIndex`
    /// selected. An out-of-range `selectedIndex` is clamped to the last tab.
    public init(tabs: [HABTab] = [], selectedIndex: Int = 0) {
        super.init(nibName: nil, bundle: nil)
        setTabs(tabs, animated: false)
        if !tabs.isEmpty {
            self.selectedIndex = min(max(selectedIndex, 0), tabs.count - 1)
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Tabs

    /// Replaces the controller's tabs. Equivalent to setting `viewControllers`
    /// with each tab's view controller (wrapped in an `HABNavigationController`
    /// where requested) and its tab bar item configured.
    public func setTabs(_ tabs: [HABTab], animated: Bool = false) {
        setViewControllers(tabs.map { Self.makeViewController(for: $0) }, animated: animated)
    }

    private static func makeViewController(for tab: HABTab) -> UIViewController {
        let container: UIViewController = tab.embedsInNavigationController
            ? HABNavigationController(rootViewController: tab.viewController)
            : tab.viewController

        let item = UITabBarItem(title: tab.title, image: tab.image, selectedImage: tab.selectedImage ?? tab.image)
        item.accessibilityIdentifier = tab.accessibilityIdentifier
        container.tabBarItem = item
        return container
    }

    // MARK: - Badges

    /// Sets the badge text on the tab at `index`. Pass `nil` to remove the badge.
    /// Does nothing if `index` is out of range.
    public func setBadgeValue(_ value: String?, forTabAt index: Int) {
        guard let viewControllers, viewControllers.indices.contains(index) else { return }
        viewControllers[index].tabBarItem.badgeValue = value
    }

    /// Shows `count` as a badge on the tab at `index`. A count of zero or less
    /// removes the badge; counts above `maximumBadgeCount` show as "99+".
    /// Does nothing if `index` is out of range.
    public func setBadgeCount(_ count: Int, forTabAt index: Int) {
        setBadgeValue(Self.badgeText(for: count), forTabAt: index)
    }

    /// The badge text currently shown on the tab at `index`, or `nil` if there's
    /// no badge or `index` is out of range.
    public func badgeValue(forTabAt index: Int) -> String? {
        guard let viewControllers, viewControllers.indices.contains(index) else { return nil }
        return viewControllers[index].tabBarItem.badgeValue
    }

    private static func badgeText(for count: Int) -> String? {
        guard count > 0 else { return nil }
        guard count <= maximumBadgeCount else {
            return "\(maximumBadgeCount.formatted())+"
        }
        return count.formatted()
    }

    // MARK: - Selection

    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        // Look the index up from the item rather than reading `selectedIndex`, which
        // UIKit may not have updated yet at this point.
        if let index = viewControllers?.firstIndex(where: { $0.tabBarItem === item }) {
            onTabSelected?(index)
        }
    }

    // MARK: - Appearance

    private func updateAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .habBackground
        appearance.shadowColor = .habBorderSubtle

        let itemAppearance = UITabBarItemAppearance()
        for state in [itemAppearance.normal, itemAppearance.selected] {
            state.badgeBackgroundColor = .habDestructive
            state.badgeTextAttributes = [.foregroundColor: UIColor.habOnDestructive]
        }
        // Secondary, not tertiary: unselected tab titles are text and need 4.5:1 contrast.
        itemAppearance.normal.iconColor = .habForegroundSecondary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.habForegroundSecondary,
            .font: UIFont.habCaption1
        ]
        itemAppearance.selected.iconColor = .habPrimary
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.habPrimary,
            .font: UIFont.habCaption1
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .habPrimary
        tabBar.unselectedItemTintColor = .habForegroundSecondary

        themeDidChange()
    }

    // MARK: - Theme

    /// Called once when the view loads and again whenever the active theme changes
    /// (on the main thread), after the tab bar's appearance has been re-applied.
    /// Override to re-apply your own fonts, `CGColor`s and radius/shadow tokens.
    /// Always call super.
    @objc open func themeDidChange() {}

    @objc private func handleThemeChange() {
        updateAppearance()
    }
}
