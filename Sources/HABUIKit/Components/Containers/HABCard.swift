//
//  HABCard.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A container view that provides a card-like appearance with rounded corners and optional elevation.
///
/// `HABCard` serves as a visual container for grouping related content. It automatically responds
/// to theme changes and adapts its appearance based on the current user interface style (light/dark mode).
///
/// ## Overview
///
/// Cards are fundamental building blocks for organizing content in modern interfaces. Use `HABCard`
/// to create visually distinct sections that help users understand content hierarchy and grouping.
///
/// The card provides three visual styles:
/// - Elevated: Uses shadow to appear raised above the surface
/// - Outlined: Uses a border without shadow for a flatter look
/// - Flat: No shadow or border for minimal visual weight
///
/// ## Creating a Card
///
/// Initialize a card and add content as subviews:
///
/// ```swift
/// let card = HABCard(style: .elevated)
/// card.addSubview(contentView)
/// NSLayoutConstraint.activate([
///     contentView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: HABSpacing.md),
///     contentView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -HABSpacing.md),
///     contentView.topAnchor.constraint(equalTo: card.topAnchor, constant: HABSpacing.md),
///     contentView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -HABSpacing.md)
/// ])
/// ```
///
/// ## Topics
///
/// ### Creating a Card
/// - ``init(style:)``
///
/// ### Configuring Appearance
/// - ``style``
/// - ``Style``
public final class HABCard: UIView {
    // MARK: - Enums

    /// The visual style of the card.
    ///
    /// Determines whether the card uses shadows, borders, or neither to create visual separation.
    public enum Style {
        /// Card with drop shadow to create elevation.
        ///
        /// Use elevated cards when you need clear visual separation from the background
        /// and want to suggest the content is on a higher layer.
        case elevated
        
        /// Card with a border and no shadow.
        ///
        /// Use outlined cards when you want visual separation without the depth
        /// implied by shadows, or when working in environments where shadows may
        /// be too heavy.
        case outlined
        
        /// Card with no shadow or border.
        ///
        /// Use flat cards when you need minimal visual treatment, relying on the
        /// card's background color alone to create separation.
        case flat
    }

    // MARK: - Public Properties

    /// The visual style of the card.
    ///
    /// Changing this property updates the card's shadow and border treatment immediately.
    public var style: Style {
        didSet { updateAppearance() }
    }

    // MARK: - Init

    /// Creates a new card with the specified style.
    ///
    /// - Parameter style: The visual style of the card. Defaults to `.elevated`.
    ///
    /// The card automatically registers for theme change notifications and trait changes,
    /// updating its appearance when the theme or user interface style changes.
    public init(style: Style = .elevated) {
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        
        // Register for trait changes (iOS 17+)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.updateAppearance()
        }
        
        updateAppearance()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        layer.cornerRadius = HABRadius.lg
        backgroundColor = .habSurface

        switch style {
            case .elevated:
                layer.borderWidth = 0
                layer.borderColor = UIColor.clear.cgColor
                HABShadow.low.apply(to: layer)
            case .outlined:
                layer.borderWidth = 1
                layer.borderColor = UIColor.habBorder.cgColor
                HABShadowStyle.clear(layer)
            case .flat:
                layer.borderWidth = 0
                layer.borderColor = UIColor.clear.cgColor
                HABShadowStyle.clear(layer)
        }
    }
}
