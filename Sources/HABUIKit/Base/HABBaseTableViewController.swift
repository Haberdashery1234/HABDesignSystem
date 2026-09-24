//
//  HABBaseTableViewController.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A UITableViewController subclass that automatically applies theme colors
/// to the view and table view, and re-applies them when the theme changes.
///
/// Colors assigned from `UIColor.hab*` update on their own when the theme changes
/// (they're dynamic; see `HABThemeTrait`). Override `themeDidChange()` for things that
/// don't: fonts, layer `CGColor`s, and radius/shadow tokens.
///
/// ```swift
/// override func themeDidChange() {
///     super.themeDidChange()
///     titleLabel.font = .habHeadline
///     cardView.layer.borderColor = UIColor.habBorder.resolvedColor(with: traitCollection).cgColor
/// }
/// ```
open class HABBaseTableViewController: UITableViewController {
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

    // MARK: - Appearance

    private func updateAppearance() {
        view.backgroundColor = .habBackground
        tableView.backgroundColor = .habBackground
        tableView.separatorColor = .habBorderSubtle
        themeDidChange()
    }

    // MARK: - Theme

    /// Called whenever the active theme changes (on the main thread). Override to
    /// re-apply fonts, `CGColor`s and radius/shadow tokens. Always call super.
    @objc open func themeDidChange() {}

    @objc private func handleThemeChange() {
        view.backgroundColor = .habBackground
        tableView.backgroundColor = .habBackground
        tableView.separatorColor = .habBorderSubtle
        themeDidChange()
    }
}
