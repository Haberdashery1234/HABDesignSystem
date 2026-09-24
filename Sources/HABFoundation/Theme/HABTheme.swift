//
//  HABTheme.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

#if canImport(UIKit)
import UIKit

/// Defines the visual identity of an app using HABUIKit.
///
/// Conform to this protocol to create a custom theme. Set it on
/// `HABThemeManager.shared.theme` at launch to brand the entire app.
///
/// Store tokens (`let`) rather than computing them on each access: components
/// read them often, and a stored value is built once per theme instance.
///
/// ```swift
/// struct MyAppTheme: HABTheme {
///     let name = "MyApp"
///
///     let colors: HABColorTokens = {
///         var tokens = HABColorTokens()
///         tokens.primary = UIColor(named: "BrandBlue")!
///         tokens.accent  = UIColor(named: "BrandGold")!
///         return tokens
///     }()
///
///     let typography = HABTypographyTokens()
///
///     // Optional — defaults are used when omitted:
///     let radius = HABRadiusTokens(lg: 20)
/// }
///
/// // In AppDelegate or App entry point:
/// HABThemeManager.shared.theme = MyAppTheme()
/// ```
public protocol HABTheme {
    /// A human-readable name for this theme. Used for debugging and logging.
    var name: String { get }

    /// The semantic color tokens for this theme.
    var colors: HABColorTokens { get }

    /// The typography token set for this theme.
    var typography: HABTypographyTokens { get }

    /// Corner radius tokens. Defaults to `HABRadiusTokens()` when not implemented.
    var radius: HABRadiusTokens { get }

    /// Elevation shadow tokens. Defaults to `HABShadowTokens()` when not implemented.
    var shadows: HABShadowTokens { get }

    /// Animation duration and spring tokens. Defaults to `HABMotionTokens()` when not implemented.
    var motion: HABMotionTokens { get }
}

// MARK: - Defaults

/// Default radius, shadow and motion tokens, so existing themes that only
/// provide colors and typography keep compiling unchanged.
public extension HABTheme {
    var radius: HABRadiusTokens { HABRadiusTokens() }
    var shadows: HABShadowTokens { HABShadowTokens() }
    var motion: HABMotionTokens { HABMotionTokens() }
}
#endif
