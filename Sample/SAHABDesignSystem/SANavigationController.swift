//
//  SANavigationController.swift
//  SAHABDesignSystem
//
//  Injects the theme-switcher palette button into every screen's
//  navigation bar automatically. Because it acts as its own delegate,
//  there is no need to add the button manually in each view controller.
//

import UIKit
import HABFoundation
import HABUIKit

final class SANavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        applyNavigationBarAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        applyNavigationBarAppearance()
    }

    private func applyNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .habBackground
        appearance.shadowColor = .habBorderSubtle
        appearance.titleTextAttributes = [.foregroundColor: UIColor.habForeground]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.habForeground]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = .habPrimary
    }
}

// MARK: - UINavigationControllerDelegate

extension SANavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        // The theme switcher doesn't need a button to push itself
        guard !(viewController is SAThemeSwitcherViewController) else { return }

        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "paintpalette"),
            style: .plain,
            target: self,
            action: #selector(openThemeSwitcher)
        )
    }

    @objc private func openThemeSwitcher() {
        pushViewController(SAThemeSwitcherViewController(), animated: true)
    }
}
