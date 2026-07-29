//
//  SceneDelegate.swift
//  HABUIKitSample
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import SwiftUI
import HABFoundation
import HABUIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let catalog = CatalogViewController()
        let uiKitNav = SampleNavigationController(rootViewController: catalog)
        window.rootViewController = uiKitNav
        self.window = window
        window.makeKeyAndVisible()
    }
}
