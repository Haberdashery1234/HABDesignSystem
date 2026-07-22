//
//  HABSpacing.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import CoreGraphics

/// Spacing constants for HABUIKit, built on a 4pt base scale.
///
/// Use these instead of hardcoded values to keep spacing consistent
/// across all apps that use the framework.
///
/// ```swift
/// stackView.spacing = HABSpacing.sm
/// view.layoutMargins = UIEdgeInsets(top: HABSpacing.md, left: HABSpacing.md,
///                                   bottom: HABSpacing.md, right: HABSpacing.md)
/// ```
public enum HABSpacing {
    // swiftlint:disable identifier_name
    /// 2pt — tight internal gaps, icon padding.
    public static let xxs: CGFloat = 2

    /// 4pt — inline spacing, small gaps between related elements.
    public static let xs: CGFloat = 4

    /// 8pt — component internal padding, tight group spacing.
    public static let sm: CGFloat = 8

    /// 16pt — standard content padding and group spacing.
    public static let md: CGFloat = 16

    /// 24pt — section spacing and generous component padding.
    public static let lg: CGFloat = 24

    /// 32pt — large section gaps.
    public static let xl: CGFloat = 32

    /// 48pt — screen-level spacing between major layout regions.
    public static let xxl: CGFloat = 48

    /// 64pt — hero and display-level gaps.
    public static let xxxl: CGFloat = 64
    
    // swiftlint:enable identifier_name
}
