//
//  HABEmptyState.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABEmptyState: UIView {
    // MARK: - Public Properties

    public var icon: UIImage? { didSet { updateAppearance() } }
    public var title: String { didSet { updateAppearance() } }
    public var message: String? { didSet { updateAppearance() } }
    public var action: HABAccessibleAction? { didSet { updateAppearance() } }

    // MARK: - Private Subviews

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    // Stack that holds all content
    private let stackView = UIStackView()

    // MARK: - Init

    public init(
        title: String,
        message: String? = nil,
        icon: UIImage? = nil,
        action: HABAccessibleAction? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.action = action
        super.init(frame: .zero)
        setupViews()
        updateAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    private func setupViews() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill

        // Icon spacer wrapper so we can set a fixed 56x56 size
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalToConstant: 56)
        ])

        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)

        // Spacing between elements
        stackView.setCustomSpacing(CGFloat(HABSpacing.md), after: iconContainer)
        stackView.setCustomSpacing(CGFloat(HABSpacing.sm), after: titleLabel)
        stackView.setCustomSpacing(CGFloat(HABSpacing.lg), after: messageLabel)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: CGFloat(HABSpacing.xl)
            ),
            stackView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -CGFloat(HABSpacing.xl)
            ),
            stackView.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: CGFloat(HABSpacing.xl)
            ),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -CGFloat(HABSpacing.xl)
            )
        ])
    }

    // MARK: - Appearance

    private func updateAppearance() {
        // Icon
        iconView.image = icon
        iconView.tintColor = .habForegroundTertiary
        iconView.isHidden = (icon == nil)
        iconView.superview?.isHidden = (icon == nil)

        // Adjust spacing: if no icon, remove the gap before title
        if let iconContainer = stackView.arrangedSubviews.first {
            stackView.setCustomSpacing(
                icon == nil ? 0 : CGFloat(HABSpacing.md),
                after: iconContainer
            )
        }

        // Title
        titleLabel.text = title
        titleLabel.font = .habHeadline
        titleLabel.textColor = .habForeground
        titleLabel.textAlignment = .center

        // Message
        messageLabel.text = message
        messageLabel.font = .habBody
        messageLabel.textColor = .habForegroundSecondary
        messageLabel.textAlignment = .center
        messageLabel.isHidden = (message == nil)

        // Action button
        if let action = action {
            var config = UIButton.Configuration.filled()
            config.title = action.label
            config.baseForegroundColor = .habOnPrimary
            config.baseBackgroundColor = .habPrimary
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 20,
                bottom: 12,
                trailing: 20
            )
            actionButton.configuration = config
            actionButton.isHidden = false
            actionButton.accessibilityLabel = action.label
        } else {
            actionButton.isHidden = true
        }

        // Accessibility
        accessibilityLabel = [title, message].compactMap { $0 }.joined(separator: ". ")
    }

    // MARK: - Actions

    @objc private func actionTapped() {
        action?.action()
    }

    // MARK: - Theme

    @objc private func themeDidChange() { updateAppearance() }
}
