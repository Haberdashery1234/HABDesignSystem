//
//  HABNavigationController.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A `UINavigationController` styled with the active HAB theme: background, title font
/// and colors, and tint. The appearance is re-applied when the theme changes.
///
/// Subclass it to add app-specific behavior; call `super.viewDidLoad()` to keep the theming.
open class HABNavigationController: UINavigationController {
    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Appearance

    private func updateAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .habBackground
        appearance.shadowColor = .habBorderSubtle

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.habForeground,
            .font: UIFont.habHeadline
        ]
        let largeTitleAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.habForeground
        ]
        appearance.titleTextAttributes = titleAttrs
        appearance.largeTitleTextAttributes = largeTitleAttrs

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = .habPrimary
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
