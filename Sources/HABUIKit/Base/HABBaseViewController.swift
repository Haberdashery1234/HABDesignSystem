//
//  HABBaseViewController.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A UIViewController subclass that automatically sets the view background
/// to the active theme's background color and re-applies it when the theme changes.
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
///
/// Set ``floatingActionButton`` to pin an ``HABFloatingActionButton`` to the bottom
/// trailing corner of the view.
open class HABBaseViewController: UIViewController {
    // MARK: - Floating Action Button

    /// A button pinned to the bottom trailing corner, above the rest of the view.
    public var floatingActionButton: HABFloatingActionButton? {
        didSet {
            guard floatingActionButton !== oldValue else { return }
            oldValue?.uninstall()
            if isViewLoaded, let floatingActionButton {
                floatingActionButton.install(in: view)
            }
        }
    }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
        if let floatingActionButton, floatingActionButton.superview == nil {
            floatingActionButton.install(in: view)
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep the button above subviews added after it.
        floatingActionButton?.updatePlacement()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        view.backgroundColor = .habBackground
        themeDidChange()
    }

    // MARK: - Theme

    /// Called whenever the active theme changes (on the main thread). Override to
    /// re-apply fonts, `CGColor`s and radius/shadow tokens. Always call super.
    @objc open func themeDidChange() {}

    @objc private func handleThemeChange() {
        view.backgroundColor = .habBackground
        themeDidChange()
    }
}
