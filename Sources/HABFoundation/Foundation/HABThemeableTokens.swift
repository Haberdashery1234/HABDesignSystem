//
//  HABThemeableTokens.swift
//  HABFoundation
//
//  Radius, shadow and motion values a theme can override. Each group's
//  default initializer reproduces the library defaults (`HABRadius`,
//  `HABShadow`, `HABAnimation`), so a theme only sets what it changes:
//
//  ```swift
//  struct RoundedTheme: HABTheme {
//      let name = "Rounded"
//      let colors = HABColorTokens()
//      let typography = HABTypographyTokens()
//      let radius = HABRadiusTokens(md: 16, lg: 24)
//  }
//  ```
//
//  Spacing is intentionally *not* themeable: it drives layout constraints,
//  and a fixed 4pt scale keeps layouts predictable across themes.
//

#if canImport(UIKit)
import UIKit

// MARK: - Radius

/// Corner radius tokens. Defaults match `HABRadius`.
public struct HABRadiusTokens: Sendable, Equatable {
    /// Sharp corners.
    public var none: CGFloat
    /// Small elements such as badges.
    public var xs: CGFloat
    /// Inputs and small cards.
    public var sm: CGFloat
    /// Standard cards, banners and buttons.
    public var md: CGFloat
    /// Large cards, toasts and sheets.
    public var lg: CGFloat
    /// Modals and feature containers.
    public var xl: CGFloat
    /// Fully rounded (chips, tags).
    public var pill: CGFloat

    public init(
        none: CGFloat = HABRadius.none,
        xs: CGFloat = HABRadius.xs,
        sm: CGFloat = HABRadius.sm,
        md: CGFloat = HABRadius.md,
        lg: CGFloat = HABRadius.lg,
        xl: CGFloat = HABRadius.xl,
        pill: CGFloat = HABRadius.pill
    ) {
        self.none = none
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.pill = pill
    }
}

// MARK: - Shadow

/// Elevation shadow tokens. Defaults match `HABShadow`.
public struct HABShadowTokens {
    /// No shadow.
    public var none: HABShadowStyle
    /// Slightly elevated surfaces such as cards.
    public var low: HABShadowStyle
    /// Interactive elements, focused containers and toasts.
    public var medium: HABShadowStyle
    /// Floating elements.
    public var high: HABShadowStyle
    /// Modals and sheets.
    public var overlay: HABShadowStyle

    public init(
        none: HABShadowStyle = HABShadow.none,
        low: HABShadowStyle = HABShadow.low,
        medium: HABShadowStyle = HABShadow.medium,
        high: HABShadowStyle = HABShadow.high,
        overlay: HABShadowStyle = HABShadow.overlay
    ) {
        self.none = none
        self.low = low
        self.medium = medium
        self.high = high
        self.overlay = overlay
    }
}

// MARK: - Motion

/// Animation duration and spring tokens. Defaults match `HABAnimation`.
///
/// Components still honor Reduce Motion (`HABAnimation.prefersReducedMotion`)
/// regardless of these values.
public struct HABMotionTokens: Sendable, Equatable {
    /// Micro-interactions such as presses and toggles.
    public var fast: TimeInterval
    /// Standard transitions and fades.
    public var normal: TimeInterval
    /// Deliberate, attention-drawing animations.
    public var slow: TimeInterval
    /// Large, multi-step sequences.
    public var verySlow: TimeInterval
    /// Low-bounce spring for most interactions (e.g. toasts arriving).
    public var gentleSpring: HABAnimation.HABSpringPreset
    /// Playful spring for celebratory moments.
    public var bouncySpring: HABAnimation.HABSpringPreset

    public init(
        fast: TimeInterval = HABAnimation.Duration.fast,
        normal: TimeInterval = HABAnimation.Duration.normal,
        slow: TimeInterval = HABAnimation.Duration.slow,
        verySlow: TimeInterval = HABAnimation.Duration.verySlow,
        gentleSpring: HABAnimation.HABSpringPreset = .gentle,
        bouncySpring: HABAnimation.HABSpringPreset = .bouncy
    ) {
        self.fast = fast
        self.normal = normal
        self.slow = slow
        self.verySlow = verySlow
        self.gentleSpring = gentleSpring
        self.bouncySpring = bouncySpring
    }
}
#endif
