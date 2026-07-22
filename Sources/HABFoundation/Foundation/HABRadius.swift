//
//  HABRadius.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import CoreGraphics

/// Corner radius constants for HABUIKit.
///
/// Use these instead of hardcoded values to keep corner rounding
/// consistent across all apps that use the framework.
///
/// ```swift
/// view.layer.cornerRadius = HABRadius.md
/// view.layer.cornerRadius = HABRadius.pill
/// ```
public enum HABRadius {
    /// 0pt — sharp corners, no rounding.
    public static let none: CGFloat = 0

    // swiftlint:disable identifier_name
    /// 4pt — subtle rounding for small elements like tags and badges.
    public static let xs: CGFloat = 4

    /// 8pt — light rounding for inputs and small cards.
    public static let sm: CGFloat = 8

    /// 12pt — standard rounding for cards and buttons.
    public static let md: CGFloat = 12

    /// 16pt — generous rounding for large cards and bottom sheets.
    public static let lg: CGFloat = 16

    /// 24pt — prominent rounding for modals and feature containers.
    public static let xl: CGFloat = 24
    // swiftlint:enable identifier_name

    /// 9999pt — fully rounded. Use for chips, toggles, and floating buttons.
    public static let pill: CGFloat = 9999
}
