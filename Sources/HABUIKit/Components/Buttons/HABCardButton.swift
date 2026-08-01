//
//  HABCardButton.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A large, card-shaped interactive tile with an optional icon, title, and subtitle.
///
/// `HABCardButton` combines the visual treatment of `HABCard` with the interactivity
/// of a button. Use it for dashboard tiles, category selectors, or any surface where
/// a standard button is too small to communicate the action clearly.
///
/// ## Overview
///
/// ```swift
/// let tile = HABCardButton(
///     style: .elevated,
///     icon: UIImage(systemName: "doc.text"),
///     title: "Reports",
///     subtitle: "View recent activity"
/// )
/// tile.addTarget(self, action: #selector(tileDidTap), for: .touchUpInside)
/// ```
///
/// ## Topics
///
/// ### Creating a Card Button
/// - ``init(style:icon:title:subtitle:)``
///
/// ### Configuring Appearance
/// - ``style``
/// - ``Style``
///
/// ### Managing Content
/// - ``icon``
/// - ``title``
/// - ``subtitle``
public final class HABCardButton: UIControl {
    // MARK: - Style

    /// The visual style of the card button.
    ///
    /// Mirrors `HABCard.Style` — elevated adds a shadow, outlined adds a border,
    /// flat uses background color alone.
    public enum Style {
        /// Card with a drop shadow to suggest elevation.
        case elevated
        /// Card with a border and no shadow.
        case outlined
        /// Card with no shadow or border.
        case flat
    }

    // MARK: - Public Properties

    /// The visual style of the card button.
    ///
    /// Changing this property updates the card's shadow and border immediately.
    public var style: Style {
        didSet { updateAppearance() }
    }

    /// The icon displayed at the top of the tile.
    ///
    /// Rendered as a template image in the primary theme color. Set to `nil` to hide
    /// the icon and collapse its space.
    public var icon: UIImage? {
        didSet { updateContent() }
    }

    public var alignment: UIStackView.Alignment {
        didSet { updateContent() }
    }
    
    public var isSquare: Bool {
        didSet { updateContent() }
    }
    
    /// The primary label of the tile.
    public var title: String? {
        didSet { updateContent() }
    }

    /// The secondary label displayed below the title.
    ///
    /// Set to `nil` to hide the subtitle and collapse its space.
    public var subtitle: String? {
        didSet { updateContent() }
    }

    // MARK: - Private Subviews

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel = HABLabel(textStyle: .subheadline)
    private let subtitleLabel = HABLabel(textStyle: .caption1)

    private let labelStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = HABSpacing.xxs
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = HABSpacing.sm
        sv.isUserInteractionEnabled = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    /// Flexible spacers above the icon and below the labels — visible only when isSquare
    /// is true, where they expand equally to center the icon+label group vertically.
    private let topSpacer = UIView()
    private let bottomSpacer = UIView()

    private var squareConstraint: NSLayoutConstraint?

    // MARK: - Init

    /// Creates a new card button.
    ///
    /// - Parameters:
    ///   - style: The visual style of the card. Defaults to `.elevated`.
    ///   - icon: An optional SF Symbol or image displayed at the top of the tile.
    ///   - title: The primary label text.
    ///   - subtitle: An optional secondary label displayed below the title.
    public init(
        style: Style = .elevated,
        icon: UIImage? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        alignment: UIStackView.Alignment = .leading,
        isSquare: Bool = false
    ) {
        self.style = style
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.alignment = alignment
        self.isSquare = isSquare
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.textColor = .habForegroundSecondary

        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(subtitleLabel)

        for spacer in [topSpacer, bottomSpacer] {
            spacer.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
            spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        }

        contentStack.addArrangedSubview(topSpacer)
        contentStack.addArrangedSubview(iconImageView)
        contentStack.addArrangedSubview(labelStack)
        contentStack.addArrangedSubview(bottomSpacer)

        addSubview(contentStack)

        squareConstraint = widthAnchor.constraint(equalTo: heightAnchor)

        NSLayoutConstraint.activate([
            bottomSpacer.heightAnchor.constraint(equalTo: topSpacer.heightAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HABSpacing.md),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -HABSpacing.md),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: HABSpacing.md),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -HABSpacing.md)
        ])

        isAccessibilityElement = true
        accessibilityTraits = .button

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.updateAppearance()
        }

        updateContent()
        updateAppearance()
    }

    // MARK: - Content

    private func updateContent() {
        squareConstraint?.isActive = isSquare
        topSpacer.isHidden = !isSquare
        bottomSpacer.isHidden = !isSquare
        labelStack.alignment = alignment
        contentStack.alignment = alignment
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconImageView.isHidden = icon == nil

        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil

        let parts = [title, subtitle].compactMap { $0 }
        accessibilityLabel = parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    // MARK: - Appearance

    @objc private func themeDidChange() {
        updateAppearance()
    }

    private func updateAppearance() {
        layer.cornerRadius = HABRadius.lg
        backgroundColor = .habSurface
        iconImageView.tintColor = .habPrimary

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

    // MARK: - Enabled State

    public override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.4 }
    }

    // MARK: - Touch Tracking

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        UIView.animate(withDuration: 0.12) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.85
        }
        return super.beginTracking(touch, with: event)
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5
        ) {
            self.transform = .identity
            self.alpha = self.isEnabled ? 1 : 0.4
        }
        super.endTracking(touch, with: event)
    }

    public override func cancelTracking(with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
            self.alpha = self.isEnabled ? 1 : 0.4
        }
        super.cancelTracking(with: event)
    }
}
