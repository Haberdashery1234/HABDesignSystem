//
//  HABThemeTrait.swift
//  HABFoundation
//
//  A custom UIKit trait that tells views "the HAB theme changed".
//
//  `HABThemeManager` bumps this trait's value on every window scene whenever
//  the theme is set. Because the trait declares `affectsColorAppearance`,
//  UIKit then re-resolves every dynamic color in those scenes — including
//  `UIColor.habPrimary` & co., wherever an app has assigned them — without
//  any view needing to observe a notification.
//

#if canImport(UIKit)
import UIKit

/// Trait whose value changes each time the active HAB theme changes.
///
/// The value is a change counter, not the theme itself: dynamic HAB colors always
/// resolve against `HABThemeManager.shared.theme`. You rarely need this directly,
/// but you can observe it to react to theme changes in your own views:
///
/// ```swift
/// registerForTraitChanges([HABThemeTrait.self]) { (self: Self, _: UITraitCollection) in
///     self.layer.borderColor = UIColor.habBorder.resolvedColor(with: self.traitCollection).cgColor
/// }
/// ```
public struct HABThemeTrait: UITraitDefinition {
    public static let defaultValue = 0
    public static let affectsColorAppearance = true
    public static let name = "HABTheme"
    public static let identifier = "com.haberdashery1234.HABDesignSystem.themeRevision"
}

public extension UITraitCollection {
    /// Change counter for the active HAB theme. See `HABThemeTrait`.
    var habThemeRevision: Int { self[HABThemeTrait.self] }
}
#endif
