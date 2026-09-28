//
//  HABDefaultTheme.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

#if canImport(UIKit)
import UIKit

/// The built-in fallback theme for HABUIKit.
///
/// Delegates to `HABAppleTheme` so the out-of-box experience uses
/// Apple's adaptive semantic colors with no visual opinion. Replace
/// it at launch with `HABLightTheme`, `HABDarkTheme`, or your own
/// `HABTheme` conformance.
///
/// ```swift
/// // AppDelegate or SceneDelegate
/// HABThemeManager.shared.theme = HABLightTheme()
/// ```
public struct HABDefaultTheme: HABTheme {
    public let name = "HABDefault"

    private let base = HABAppleTheme()

    public var colors: HABColorTokens { base.colors }
    public var typography: HABTypographyTokens { base.typography }
    public var radius: HABRadiusTokens { base.radius }
    public var shadows: HABShadowTokens { base.shadows }
    public var motion: HABMotionTokens { base.motion }

    public init() {}
}
#endif
