//
//  SASceneDelegate.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import SwiftUI
import HABFoundation
import HABUIKit

class SASceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let catalog = SACatalogViewController()
        let uiKitNav = SANavigationController(rootViewController: catalog)
        window.rootViewController = uiKitNav
        self.window = window
        window.makeKeyAndVisible()
    }
}
