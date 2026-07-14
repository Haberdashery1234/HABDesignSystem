//
//  HABColors.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

/// Semantic color tokens for HABUIKit.
///
/// Themes provide values by creating an `HABColorTokens` instance and
/// overriding any properties they need. All properties have sensible
/// adaptive defaults that work out of the box with no theme configured.
///
/// ```swift
/// var colors: HABColorTokens {
///     var tokens = HABColorTokens()
///     tokens.primary = UIColor(named: "BrandBlue")!
///     tokens.accent  = UIColor(named: "BrandOrange")!
///     return tokens
/// }
/// ```
public struct HABColorTokens {
    // MARK: - Brand

    /// Primary brand color. Used for main CTAs, active states, and key interactive elements.
    public var primary: UIColor

    /// Secondary brand color. Used for supporting UI elements and secondary actions.
    public var secondary: UIColor

    /// Accent color. Used sparingly for highlights and emphasis.
    public var accent: UIColor

    // MARK: - Backgrounds

    /// Main app background. Maps to `UIColor.systemBackground` by default.
    public var background: UIColor

    /// Secondary background. Used for grouped content, sidebars, and inset sections.
    public var backgroundSecondary: UIColor

    /// Surface background. Used for cards and elevated containers at the first level.
    public var surface: UIColor

    /// Elevated surface background. Used for modals, sheets, and popovers.
    public var surfaceElevated: UIColor

    // MARK: - Foreground

    /// Primary text and icon color.
    public var foreground: UIColor

    /// Secondary text. Used for subtitles, metadata, and supporting copy.
    public var foregroundSecondary: UIColor

    /// Tertiary text. Used for hints, timestamps, and low-emphasis content.
    public var foregroundTertiary: UIColor

    /// Disabled text and icon color.
    public var foregroundDisabled: UIColor

    /// Inverted foreground. Used for text placed on dark or brand-colored surfaces.
    public var foregroundInverted: UIColor

    // MARK: - On-Brand

    /// Content color for elements placed on a `primary`-colored surface.
    public var onPrimary: UIColor

    /// Content color for elements placed on a `secondary`-colored surface.
    public var onSecondary: UIColor

    // MARK: - Semantic States

    /// Destructive action color. Used for delete, remove, and error states.
    public var destructive: UIColor

    /// Tinted background for destructive state containers and banners.
    public var destructiveSurface: UIColor

    /// Success state color.
    public var success: UIColor

    /// Tinted background for success state containers and banners.
    public var successSurface: UIColor

    /// Warning state color.
    public var warning: UIColor

    /// Tinted background for warning state containers and banners.
    public var warningSurface: UIColor

    /// Informational state color.
    public var info: UIColor

    /// Tinted background for info state containers and banners.
    public var infoSurface: UIColor

    // MARK: - UI Chrome

    /// Standard border and divider color.
    public var border: UIColor

    /// Subtle border. Used for low-emphasis separators and hairlines.
    public var borderSubtle: UIColor

    /// Overlay color for modal dimming backgrounds.
    public var overlay: UIColor

    // MARK: - Init

    /// Creates a color token set. All parameters have adaptive defaults
    /// so only the values you want to override need to be specified.
    public init(
        primary: UIColor              = .systemBlue,
        secondary: UIColor            = .systemIndigo,
        accent: UIColor               = .systemOrange,
        background: UIColor           = .systemBackground,
        backgroundSecondary: UIColor  = .secondarySystemBackground,
        surface: UIColor              = .secondarySystemBackground,
        surfaceElevated: UIColor      = .tertiarySystemBackground,
        foreground: UIColor           = .label,
        foregroundSecondary: UIColor  = .secondaryLabel,
        foregroundTertiary: UIColor   = .tertiaryLabel,
        foregroundDisabled: UIColor   = .quaternaryLabel,
        foregroundInverted: UIColor   = UIColor(dynamicProvider: { traits in
            traits.userInterfaceStyle == .dark ? .black : .white
        }),
        onPrimary: UIColor            = .white,
        onSecondary: UIColor          = .white,
        destructive: UIColor          = .systemRed,
        destructiveSurface: UIColor   = UIColor(dynamicProvider: { _ in .systemRed.withAlphaComponent(0.12) }),
        success: UIColor              = .systemGreen,
        successSurface: UIColor       = UIColor(dynamicProvider: { _ in .systemGreen.withAlphaComponent(0.12) }),
        warning: UIColor              = .systemOrange,
        warningSurface: UIColor       = UIColor(dynamicProvider: { _ in .systemOrange.withAlphaComponent(0.12) }),
        info: UIColor                 = .systemBlue,
        infoSurface: UIColor          = UIColor(dynamicProvider: { _ in .systemBlue.withAlphaComponent(0.12) }),
        border: UIColor               = .separator,
        borderSubtle: UIColor         = UIColor(dynamicProvider: { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.08)
                : UIColor.black.withAlphaComponent(0.08)
        }),
        overlay: UIColor              = UIColor(dynamicProvider: { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.6)
                : UIColor.black.withAlphaComponent(0.4)
        })
    ) {
        self.primary             = primary
        self.secondary           = secondary
        self.accent              = accent
        self.background          = background
        self.backgroundSecondary = backgroundSecondary
        self.surface             = surface
        self.surfaceElevated     = surfaceElevated
        self.foreground          = foreground
        self.foregroundSecondary = foregroundSecondary
        self.foregroundTertiary  = foregroundTertiary
        self.foregroundDisabled  = foregroundDisabled
        self.foregroundInverted  = foregroundInverted
        self.onPrimary           = onPrimary
        self.onSecondary         = onSecondary
        self.destructive         = destructive
        self.destructiveSurface  = destructiveSurface
        self.success             = success
        self.successSurface      = successSurface
        self.warning             = warning
        self.warningSurface      = warningSurface
        self.info                = info
        self.infoSurface         = infoSurface
        self.border              = border
        self.borderSubtle        = borderSubtle
        self.overlay             = overlay
    }
}
