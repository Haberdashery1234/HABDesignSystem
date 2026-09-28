//
//  UIColor+HAB.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// Convenience access to the active theme's semantic color tokens.
///
/// Colors are resolved at call time from the active `HABThemeManager` theme,
/// so they always reflect the current theme — including any runtime theme changes.
///
/// ```swift
/// label.textColor       = .habForeground
/// view.backgroundColor  = .habSurface
/// button.tintColor      = .habPrimary
/// ```
public extension UIColor {
    // MARK: - Brand

    /// Primary brand color. See `HABColorTokens.primary`.
    static var habPrimary: UIColor { HABThemeManager.shared.theme.colors.primary }

    /// Secondary brand color. See `HABColorTokens.secondary`.
    static var habSecondary: UIColor { HABThemeManager.shared.theme.colors.secondary }

    /// Accent color. See `HABColorTokens.accent`.
    static var habAccent: UIColor { HABThemeManager.shared.theme.colors.accent }

    // MARK: - Backgrounds

    /// Main app background. See `HABColorTokens.background`.
    static var habBackground: UIColor { HABThemeManager.shared.theme.colors.background }

    /// Secondary background. See `HABColorTokens.backgroundSecondary`.
    static var habBackgroundSecondary: UIColor { HABThemeManager.shared.theme.colors.backgroundSecondary }

    /// Surface background. See `HABColorTokens.surface`.
    static var habSurface: UIColor { HABThemeManager.shared.theme.colors.surface }

    /// Elevated surface background. See `HABColorTokens.surfaceElevated`.
    static var habSurfaceElevated: UIColor { HABThemeManager.shared.theme.colors.surfaceElevated }

    // MARK: - Foreground

    /// Primary text and icon color. See `HABColorTokens.foreground`.
    static var habForeground: UIColor { HABThemeManager.shared.theme.colors.foreground }

    /// Secondary text color. See `HABColorTokens.foregroundSecondary`.
    static var habForegroundSecondary: UIColor { HABThemeManager.shared.theme.colors.foregroundSecondary }

    /// Tertiary text color. See `HABColorTokens.foregroundTertiary`.
    static var habForegroundTertiary: UIColor { HABThemeManager.shared.theme.colors.foregroundTertiary }

    /// Disabled text and icon color. See `HABColorTokens.foregroundDisabled`.
    static var habForegroundDisabled: UIColor { HABThemeManager.shared.theme.colors.foregroundDisabled }

    /// Inverted foreground color. See `HABColorTokens.foregroundInverted`.
    static var habForegroundInverted: UIColor { HABThemeManager.shared.theme.colors.foregroundInverted }

    // MARK: - On-Brand

    /// Content color for elements on a primary-colored surface. See `HABColorTokens.onPrimary`.
    static var habOnPrimary: UIColor { HABThemeManager.shared.theme.colors.onPrimary }

    /// Content color for elements on a secondary-colored surface. See `HABColorTokens.onSecondary`.
    static var habOnSecondary: UIColor { HABThemeManager.shared.theme.colors.onSecondary }

    /// Content color for elements on a destructive-colored surface. See `HABColorTokens.onDestructive`.
    static var habOnDestructive: UIColor { HABThemeManager.shared.theme.colors.onDestructive }

    // MARK: - Semantic States

    /// Destructive action color. See `HABColorTokens.destructive`.
    static var habDestructive: UIColor { HABThemeManager.shared.theme.colors.destructive }

    /// Destructive tinted surface color. See `HABColorTokens.destructiveSurface`.
    static var habDestructiveSurface: UIColor { HABThemeManager.shared.theme.colors.destructiveSurface }

    /// Success state color. See `HABColorTokens.success`.
    static var habSuccess: UIColor { HABThemeManager.shared.theme.colors.success }

    /// Success tinted surface color. See `HABColorTokens.successSurface`.
    static var habSuccessSurface: UIColor { HABThemeManager.shared.theme.colors.successSurface }

    /// Warning state color. See `HABColorTokens.warning`.
    static var habWarning: UIColor { HABThemeManager.shared.theme.colors.warning }

    /// Warning tinted surface color. See `HABColorTokens.warningSurface`.
    static var habWarningSurface: UIColor { HABThemeManager.shared.theme.colors.warningSurface }

    /// Informational state color. See `HABColorTokens.info`.
    static var habInfo: UIColor { HABThemeManager.shared.theme.colors.info }

    /// Info tinted surface color. See `HABColorTokens.infoSurface`.
    static var habInfoSurface: UIColor { HABThemeManager.shared.theme.colors.infoSurface }

    // MARK: - UI Chrome

    /// Standard border and divider color. See `HABColorTokens.border`.
    static var habBorder: UIColor { HABThemeManager.shared.theme.colors.border }

    /// Subtle border color. See `HABColorTokens.borderSubtle`.
    static var habBorderSubtle: UIColor { HABThemeManager.shared.theme.colors.borderSubtle }

    /// Modal dimming overlay color. See `HABColorTokens.overlay`.
    static var habOverlay: UIColor { HABThemeManager.shared.theme.colors.overlay }
}
