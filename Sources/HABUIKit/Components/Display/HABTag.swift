//
//  HABTag.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABTag: UIView {
    // MARK: - Public Types

    public enum Style {
        case filled
        case outlined
        case subtle
    }

    public enum Color {
        case primary
        case success
        case warning
        case destructive
        case neutral
    }

    // MARK: - Public Properties

    public var label: String {
        didSet { updateAppearance() }
    }

    public var style: Style {
        didSet { updateAppearance() }
    }

    public var color: Color {
        didSet { updateAppearance() }
    }

    public var showsLeadingDot: Bool = false {
        didSet { updateAppearance() }
    }

    public var dismissAction: HABAccessibleAction? {
        didSet { updateAppearance() }
    }

    // MARK: - Private Subviews

    private let dotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    public init(label: String = "", style: Style = .filled, color: Color = .primary) {
        self.label = label
        self.style = style
        self.color = color
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        setupView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )

        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        layer.cornerRadius = HABRadius.pill
        clipsToBounds = true

        addSubview(dotView)
        addSubview(textLabel)
        addSubview(dismissButton)

        // Configure dismiss button icon
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let xImage = UIImage(systemName: "xmark", withConfiguration: config)
        dismissButton.setImage(xImage, for: .normal)
        dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Dot view
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HABSpacing.sm),
            dotView.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 6),
            dotView.heightAnchor.constraint(equalToConstant: 6),

            // Text label
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: HABSpacing.xs),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -HABSpacing.xs),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Dismiss button
            dismissButton.widthAnchor.constraint(equalToConstant: 16),
            dismissButton.heightAnchor.constraint(equalToConstant: 16),
            dismissButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -HABSpacing.sm)
        ])

        // Leading of text label depends on dot visibility (resolved in updateAppearance)
        // Trailing of text label depends on dismiss button visibility
        // We set these up with dynamic constraints in updateAppearance
    }

    // MARK: - Dynamic Constraints

    private var textLabelLeadingToDot: NSLayoutConstraint?
    private var textLabelLeadingToView: NSLayoutConstraint?
    private var textLabelTrailingToDismiss: NSLayoutConstraint?
    private var textLabelTrailingToView: NSLayoutConstraint?

    private func setupDynamicConstraints() {
        // Remove old dynamic constraints
        textLabelLeadingToDot?.isActive = false
        textLabelLeadingToView?.isActive = false
        textLabelTrailingToDismiss?.isActive = false
        textLabelTrailingToView?.isActive = false

        if showsLeadingDot {
            textLabelLeadingToDot = textLabel.leadingAnchor.constraint(
                equalTo: dotView.trailingAnchor, constant: HABSpacing.xs
            )
            textLabelLeadingToDot?.isActive = true
        } else {
            textLabelLeadingToView = textLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: HABSpacing.sm
            )
            textLabelLeadingToView?.isActive = true
        }

        if dismissAction != nil {
            textLabelTrailingToDismiss = textLabel.trailingAnchor.constraint(
                equalTo: dismissButton.leadingAnchor, constant: -HABSpacing.xs
            )
            textLabelTrailingToDismiss?.isActive = true
        } else {
            textLabelTrailingToView = textLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -HABSpacing.sm
            )
            textLabelTrailingToView?.isActive = true
        }
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // Resolve colors for current color value
        let colors = resolvedColors(for: color)
        let fgColor = colors.foreground
        let tintedBg = colors.background
        let borderColor = colors.border

        // Apply style
        switch style {
            case .filled:
                backgroundColor = tintedBg
                layer.borderWidth = 0
            case .outlined:
                backgroundColor = .clear
                layer.borderWidth = 1
                layer.borderColor = borderColor.cgColor
            case .subtle:
                backgroundColor = tintedBg.withAlphaComponent(0.5)
                layer.borderWidth = 0
        }

        // Text label
        textLabel.text = label
        textLabel.font = .habCaption1
        textLabel.textColor = fgColor

        // Dot view
        dotView.backgroundColor = fgColor
        dotView.isHidden = !showsLeadingDot

        // Dismiss button
        let hasDismiss = dismissAction != nil
        dismissButton.isHidden = !hasDismiss
        dismissButton.tintColor = fgColor
        dismissButton.accessibilityLabel = dismissAction?.label

        // Rebuild dynamic constraints
        setupDynamicConstraints()

        // Accessibility
        isAccessibilityElement = true
        accessibilityLabel = label
        if hasDismiss {
            accessibilityTraits = [.button]
        } else {
            accessibilityTraits = [.staticText]
        }

        setNeedsLayout()
    }

    private struct TagColors {
        let foreground: UIColor
        let background: UIColor
        let border: UIColor
    }

    private func resolvedColors(for color: Color) -> TagColors {
        switch color {
            case .primary:
                return TagColors(foreground: .habPrimary, background: .habPrimary.withAlphaComponent(0.12), border: .habPrimary)
            case .success:
                return TagColors(foreground: .habSuccess, background: .habSuccessSurface, border: .habSuccess)
            case .warning:
                return TagColors(foreground: .habWarning, background: .habWarningSurface, border: .habWarning)
            case .destructive:
                return TagColors(foreground: .habDestructive, background: .habDestructiveSurface, border: .habDestructive)
            case .neutral:
                return TagColors(foreground: .habForegroundSecondary, background: .habSurface, border: .habBorder)
        }
    }

    // MARK: - Actions

    @objc private func handleDismiss() {
        dismissAction?.action()
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
