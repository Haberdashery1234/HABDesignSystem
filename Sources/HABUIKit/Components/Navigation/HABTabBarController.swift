//
//  HABTabBarController.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

public class HABTabBarController: UITabBarController {
    // MARK: - Lifecycle

    public override func viewDidLoad() {
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
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .habBackground
        appearance.shadowColor = .habBorderSubtle

        let itemAppearance = UITabBarItemAppearance()
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
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
