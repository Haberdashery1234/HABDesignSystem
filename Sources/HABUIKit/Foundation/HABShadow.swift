//
//  HABShadow.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

// MARK: - HABShadowStyle

/// A shadow definition applied to a `CALayer`.
///
/// ```swift
/// HABShadow.low.apply(to: card.layer)
/// HABShadow.medium.apply(to: modal.layer)
/// ```
public struct HABShadowStyle {
    /// Shadow color. Defaults to black; adjust opacity separately.
    public var color: UIColor

    /// Shadow opacity. `0` is invisible, `1` is fully opaque.
    public var opacity: Float

    /// Shadow blur radius in points.
    public var radius: CGFloat

    /// Shadow offset in points.
    public var offset: CGSize

    public init(color: UIColor, opacity: Float, radius: CGFloat, offset: CGSize) {
        self.color   = color
        self.opacity = opacity
        self.radius  = radius
        self.offset  = offset
    }

    /// Applies this shadow to the given `CALayer`.
    ///
    /// Also sets `masksToBounds` to `false`, which is required for
    /// shadows to be visible.
    public func apply(to layer: CALayer) {
        layer.masksToBounds  = false
        layer.shadowColor    = color.cgColor
        layer.shadowOpacity  = opacity
        layer.shadowRadius   = radius
        layer.shadowOffset   = offset
    }

    /// Removes any shadow from the given `CALayer`.
    public static func clear(_ layer: CALayer) {
        layer.shadowOpacity = 0
    }
}

// MARK: - HABShadow

/// Shadow presets for HABUIKit.
///
/// Shadows increase in elevation from `low` to `high`.
/// Use `overlay` for modal dimming layers, not for view elevation.
///
/// ```swift
/// HABShadow.low.apply(to: cardView.layer)
/// HABShadow.high.apply(to: floatingButton.layer)
/// ```
public enum HABShadow {
    /// No shadow.
    public static let none = HABShadowStyle(
        color: .black,
        opacity: 0,
        radius: 0,
        offset: .zero
    )

    /// Subtle shadow for slightly elevated surfaces like cards.
    public static let low = HABShadowStyle(
        color: .black,
        opacity: 0.06,
        radius: 4,
        offset: CGSize(width: 0, height: 2)
    )

    /// Medium shadow for interactive elements and focused containers.
    public static let medium = HABShadowStyle(
        color: .black,
        opacity: 0.10,
        radius: 8,
        offset: CGSize(width: 0, height: 4)
    )

    /// Strong shadow for floating elements like FABs and tooltips.
    public static let high = HABShadowStyle(
        color: .black,
        opacity: 0.16,
        radius: 16,
        offset: CGSize(width: 0, height: 8)
    )

    /// Heavy shadow for modals and bottom sheets.
    public static let overlay = HABShadowStyle(
        color: .black,
        opacity: 0.24,
        radius: 24,
        offset: CGSize(width: 0, height: 12)
    )
}
