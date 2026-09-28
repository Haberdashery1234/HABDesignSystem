//
//  HABThemeManager.swift
//  HABFoundation
//
//  Created by Christian Grise on 6/29/26.
//

#if canImport(UIKit)
import UIKit

/// Manages the active HAB theme for the app.
///
/// Set a theme once at launch and all HAB components will reflect it:
///
/// ```swift
/// // AppDelegate.application(_:didFinishLaunchingWithOptions:)
/// HABThemeManager.shared.theme = MyAppTheme()
/// ```
///
/// ## How theme changes reach the UI
///
/// When `theme` is set, the manager:
/// 1. Updates `HABThemeTrait` on every connected window scene. UIKit then
///    re-resolves dynamic colors (`UIColor.habPrimary`, etc.) everywhere they're
///    used — including colors your app assigned — with no observers needed.
/// 2. Posts `themeDidChangeNotification`, for things traits can't update on their
///    own: fonts, `CGColor`s (layer borders and shadows), radius and shadow tokens.
///    HAB components and base view controllers handle this automatically.
///
/// ## Threading
///
/// `theme` can be read and set from any thread. The trait update and the
/// notification always happen on the main thread — synchronously if the theme
/// was set on the main thread, otherwise asynchronously.
public final class HABThemeManager: @unchecked Sendable {
    // `@unchecked Sendable`: all mutable state is guarded by `lock`.

    // MARK: - Shared Instance

    /// The shared theme manager. Use this to get and set the active theme.
    public static let shared = HABThemeManager()

    private init() {}

    // MARK: - State

    private let lock = NSLock()
    private var storedTheme: any HABTheme = HABDefaultTheme()
    private var revision = 0

    // MARK: - Theme

    /// The currently active theme.
    ///
    /// Setting this updates `HABThemeTrait` on all window scenes and broadcasts
    /// `themeDidChangeNotification` (on the main thread).
    public var theme: any HABTheme {
        get { lock.withLock { storedTheme } }
        set {
            let newRevision = lock.withLock {
                storedTheme = newValue
                revision += 1
                return revision
            }
            broadcast(themeName: newValue.name, revision: newRevision)
        }
    }

    // MARK: - Notifications

    /// Posted on `NotificationCenter.default`, on the main thread, whenever the
    /// active theme changes.
    ///
    /// Colors update automatically through `HABThemeTrait`; observe this for
    /// anything else that depends on the theme (fonts, `CGColor`s, radii, shadows).
    /// `HABBaseViewController` and its subclasses already observe it and call
    /// `themeDidChange()`.
    ///
    /// ```swift
    /// NotificationCenter.default.addObserver(
    ///     self,
    ///     selector: #selector(themeDidChange),
    ///     name: HABThemeManager.themeDidChangeNotification,
    ///     object: nil
    /// )
    /// ```
    public static let themeDidChangeNotification = Notification.Name("HABThemeManagerThemeDidChange")

    /// The `userInfo` key for the incoming theme's `name` string.
    public static let themeNameKey = "HABThemeManagerThemeNameKey"

    // MARK: - Broadcasting

    private func broadcast(themeName: String, revision: Int) {
        let work: @MainActor @Sendable () -> Void = { [self] in
            Self.applyThemeTrait(revision: revision)
            NotificationCenter.default.post(
                name: Self.themeDidChangeNotification,
                object: self,
                userInfo: [Self.themeNameKey: themeName]
            )
        }
        if Thread.isMainThread {
            MainActor.assumeIsolated(work)
        } else {
            DispatchQueue.main.async {
                MainActor.assumeIsolated(work)
            }
        }
    }

    /// Sets `HABThemeTrait` on every connected window scene so UIKit re-resolves
    /// dynamic colors. Scenes connected later start from the trait's default value,
    /// which is fine: dynamic HAB colors always resolve against the current theme.
    @MainActor
    private static func applyThemeTrait(revision: Int) {
        // Looked up via KVC so this compiles for app extensions and is a no-op
        // where there's no UIApplication (e.g. non-hosted unit tests).
        guard let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication else {
            return
        }
        for case let scene as UIWindowScene in application.connectedScenes {
            scene.traitOverrides[HABThemeTrait.self] = revision
        }
    }
}
#endif
