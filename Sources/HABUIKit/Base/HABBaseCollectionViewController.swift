//
//  HABBaseCollectionViewController.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

/// A UICollectionViewController subclass that automatically applies theme colors
/// to the view and collection view, and re-applies them when the theme changes.
///
/// Subclass this and override `themeDidChange()` to respond to theme changes:
///
/// ```swift
/// override func themeDidChange() {
///     super.themeDidChange()
///     myLabel.textColor = .habForeground
/// }
/// ```
open class HABBaseCollectionViewController: UICollectionViewController {
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
        collectionView.backgroundColor = .habBackground
        themeDidChange()
    }

    // MARK: - Theme

    /// Called whenever the active theme changes. Override in subclasses to update
    /// component colors. Always call super.
    @objc open func themeDidChange() {}

    @objc private func handleThemeChange() {
        view.backgroundColor = .habBackground
        collectionView.backgroundColor = .habBackground
        themeDidChange()
    }
}
