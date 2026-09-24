//
//  HABThemeAccess.swift
//  HABUIKit
//

import HABFoundation

/// Shorthand for the active theme inside HABUIKit components.
///
/// Read tokens at the point of use (in `updateAppearance()`, or right before an
/// animation) so theme changes take effect the next time they run.
var habTheme: any HABTheme { HABThemeManager.shared.theme }
