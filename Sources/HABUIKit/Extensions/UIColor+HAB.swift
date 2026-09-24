//
//  UIColor+HAB.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// Semantic colors from the active theme.
///
/// These are **dynamic** colors: each resolves against `HABThemeManager.shared.theme`
/// whenever UIKit draws with it. Assign one once and it stays correct — when the
/// theme changes, `HABThemeTrait` makes UIKit re-resolve it automatically, and
/// light/dark adaptive tokens (e.g. in `HABAppleTheme`) follow the system appearance.
///
/// ```swift
/// label.textColor       = .habForeground
/// view.backgroundColor  = .habSurface
/// button.tintColor      = .habPrimary
/// ```
///
/// `CGColor`s are snapshots: re-apply `layer.borderColor` / `shadowColor` when
/// `themeDidChangeNotification` fires or `HABThemeTrait` changes, resolving with the
/// view's trait collection, e.g. `UIColor.habBorder.resolvedColor(with: traitCollection).cgColor`.
///
/// Each property returns the same instance every time, so identity comparisons work.
public extension UIColor {
    // MARK: - Brand

    /// Primary brand color. See `HABColorTokens.primary`.
    static var habPrimary: UIColor { HABThemedColors.primary }

    /// Secondary brand color. See `HABColorTokens.secondary`.
    static var habSecondary: UIColor { HABThemedColors.secondary }

    /// Accent color. See `HABColorTokens.accent`.
    static var habAccent: UIColor { HABThemedColors.accent }

    // MARK: - Backgrounds

    /// Main app background. See `HABColorTokens.background`.
    static var habBackground: UIColor { HABThemedColors.background }

    /// Secondary background. See `HABColorTokens.backgroundSecondary`.
    static var habBackgroundSecondary: UIColor { HABThemedColors.backgroundSecondary }

    /// Surface background. See `HABColorTokens.surface`.
    static var habSurface: UIColor { HABThemedColors.surface }

    /// Elevated surface background. See `HABColorTokens.surfaceElevated`.
    static var habSurfaceElevated: UIColor { HABThemedColors.surfaceElevated }

    // MARK: - Foreground

    /// Primary text and icon color. See `HABColorTokens.foreground`.
    static var habForeground: UIColor { HABThemedColors.foreground }

    /// Secondary text color. See `HABColorTokens.foregroundSecondary`.
    static var habForegroundSecondary: UIColor { HABThemedColors.foregroundSecondary }

    /// Tertiary text color. See `HABColorTokens.foregroundTertiary`.
    static var habForegroundTertiary: UIColor { HABThemedColors.foregroundTertiary }

    /// Disabled text and icon color. See `HABColorTokens.foregroundDisabled`.
    static var habForegroundDisabled: UIColor { HABThemedColors.foregroundDisabled }

    /// Inverted foreground color. See `HABColorTokens.foregroundInverted`.
    static var habForegroundInverted: UIColor { HABThemedColors.foregroundInverted }

    // MARK: - On-Brand

    /// Content color for elements on a primary-colored surface. See `HABColorTokens.onPrimary`.
    static var habOnPrimary: UIColor { HABThemedColors.onPrimary }

    /// Content color for elements on a secondary-colored surface. See `HABColorTokens.onSecondary`.
    static var habOnSecondary: UIColor { HABThemedColors.onSecondary }

    /// Content color for elements on a destructive-colored surface. See `HABColorTokens.onDestructive`.
    static var habOnDestructive: UIColor { HABThemedColors.onDestructive }

    // MARK: - Semantic States

    /// Destructive action color. See `HABColorTokens.destructive`.
    static var habDestructive: UIColor { HABThemedColors.destructive }

    /// Destructive tinted surface color. See `HABColorTokens.destructiveSurface`.
    static var habDestructiveSurface: UIColor { HABThemedColors.destructiveSurface }

    /// Success state color. See `HABColorTokens.success`.
    static var habSuccess: UIColor { HABThemedColors.success }

    /// Success tinted surface color. See `HABColorTokens.successSurface`.
    static var habSuccessSurface: UIColor { HABThemedColors.successSurface }

    /// Warning state color. See `HABColorTokens.warning`.
    static var habWarning: UIColor { HABThemedColors.warning }

    /// Warning tinted surface color. See `HABColorTokens.warningSurface`.
    static var habWarningSurface: UIColor { HABThemedColors.warningSurface }

    /// Informational state color. See `HABColorTokens.info`.
    static var habInfo: UIColor { HABThemedColors.info }

    /// Info tinted surface color. See `HABColorTokens.infoSurface`.
    static var habInfoSurface: UIColor { HABThemedColors.infoSurface }

    // MARK: - UI Chrome

    /// Standard border and divider color. See `HABColorTokens.border`.
    static var habBorder: UIColor { HABThemedColors.border }

    /// Subtle border color. See `HABColorTokens.borderSubtle`.
    static var habBorderSubtle: UIColor { HABThemedColors.borderSubtle }

    /// Modal dimming overlay color. See `HABColorTokens.overlay`.
    static var habOverlay: UIColor { HABThemedColors.overlay }

}

// MARK: - Cached dynamic colors

/// One dynamic `UIColor` per token, created once.
///
/// `nonisolated(unsafe)`: the colors are immutable, and their providers only read
/// the (thread-safe) theme manager.
enum HABThemedColors {
    /// Creates a dynamic color that picks a token from the active theme and resolves
    /// it for the requesting traits (so adaptive theme colors keep adapting).
    static func themed(_ pick: @escaping @Sendable (HABColorTokens) -> UIColor) -> UIColor {
        UIColor { traits in
            pick(HABThemeManager.shared.theme.colors).resolvedColor(with: traits)
        }
    }


    nonisolated(unsafe) static let primary = themed { $0.primary }
    nonisolated(unsafe) static let secondary = themed { $0.secondary }
    nonisolated(unsafe) static let accent = themed { $0.accent }

    nonisolated(unsafe) static let background = themed { $0.background }
    nonisolated(unsafe) static let backgroundSecondary = themed { $0.backgroundSecondary }
    nonisolated(unsafe) static let surface = themed { $0.surface }
    nonisolated(unsafe) static let surfaceElevated = themed { $0.surfaceElevated }

    nonisolated(unsafe) static let foreground = themed { $0.foreground }
    nonisolated(unsafe) static let foregroundSecondary = themed { $0.foregroundSecondary }
    nonisolated(unsafe) static let foregroundTertiary = themed { $0.foregroundTertiary }
    nonisolated(unsafe) static let foregroundDisabled = themed { $0.foregroundDisabled }
    nonisolated(unsafe) static let foregroundInverted = themed { $0.foregroundInverted }

    nonisolated(unsafe) static let onPrimary = themed { $0.onPrimary }
    nonisolated(unsafe) static let onSecondary = themed { $0.onSecondary }
    nonisolated(unsafe) static let onDestructive = themed { $0.onDestructive }

    nonisolated(unsafe) static let destructive = themed { $0.destructive }
    nonisolated(unsafe) static let destructiveSurface = themed { $0.destructiveSurface }
    nonisolated(unsafe) static let success = themed { $0.success }
    nonisolated(unsafe) static let successSurface = themed { $0.successSurface }
    nonisolated(unsafe) static let warning = themed { $0.warning }
    nonisolated(unsafe) static let warningSurface = themed { $0.warningSurface }
    nonisolated(unsafe) static let info = themed { $0.info }
    nonisolated(unsafe) static let infoSurface = themed { $0.infoSurface }

    nonisolated(unsafe) static let border = themed { $0.border }
    nonisolated(unsafe) static let borderSubtle = themed { $0.borderSubtle }
    nonisolated(unsafe) static let overlay = themed { $0.overlay }
}
