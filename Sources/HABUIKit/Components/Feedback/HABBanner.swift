//
//  HABBanner.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABBanner: UIView {
    // MARK: - Style

    public enum Style {
        case info, success, warning, error
    }

    // MARK: - Public Properties

    public var title: String { didSet { updateAppearance() } }
    public var message: String? { didSet { updateAppearance() } }
    public var style: Style { didSet { updateAppearance() } }
    public var action: HABAccessibleAction? { didSet { updateAppearance() } }
    public var dismissAction: HABAccessibleAction? { didSet { updateAppearance() } }

    // MARK: - Private Subviews

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let dismissButton = UIButton(type: .system)

    // MARK: - Init

    public init(
        title: String,
        message: String? = nil,
        style: Style = .info,
        action: HABAccessibleAction? = nil,
        dismissAction: HABAccessibleAction? = nil
    ) {
        self.title = title
        self.message = message
        self.style = style
        self.action = action
        self.dismissAction = dismissAction
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
        layer.cornerRadius = HABRadius.md
        layer.masksToBounds = true

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = .habSubheadline
        actionButton.contentHorizontalAlignment = .leading
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionButton)
        addSubview(dismissButton)

        let pad = CGFloat(HABSpacing.md)
        let iconToText = CGFloat(HABSpacing.sm)
        let textToText = CGFloat(HABSpacing.xs)
        let iconSize: CGFloat = 20
        let dismissSize: CGFloat = 20

        NSLayoutConstraint.activate([
            // Icon
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize),

            // Dismiss button
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            dismissButton.widthAnchor.constraint(equalToConstant: dismissSize),
            dismissButton.heightAnchor.constraint(equalToConstant: dismissSize),

            // Title
            titleLabel.leadingAnchor.constraint(
                equalTo: iconView.trailingAnchor,
                constant: iconToText
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: dismissButton.leadingAnchor,
                constant: -iconToText
            ),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: pad),

            // Message
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: textToText
            ),

            // Action button
            actionButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionButton.topAnchor.constraint(
                equalTo: messageLabel.bottomAnchor,
                constant: textToText
            ),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad)
        ])
    }

    // MARK: - Appearance

    private func updateAppearance() {
        let bgColor: UIColor
        let iconName: String
        let tintColor: UIColor

        switch style {
            case .info:
                bgColor = .habInfoSurface
                iconName = "info.circle.fill"
                tintColor = .habInfo
            case .success:
                bgColor = .habSuccessSurface
                iconName = "checkmark.circle.fill"
                tintColor = .habSuccess
            case .warning:
                bgColor = .habWarningSurface
                iconName = "exclamationmark.triangle.fill"
                tintColor = .habWarning
            case .error:
                bgColor = .habDestructiveSurface
                iconName = "xmark.circle.fill"
                tintColor = .habDestructive
        }

        backgroundColor = bgColor
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = tintColor

        titleLabel.text = title
        titleLabel.font = .habHeadline
        titleLabel.textColor = .habForeground

        messageLabel.text = message
        messageLabel.font = .habSubheadline
        messageLabel.textColor = .habForegroundSecondary
        messageLabel.isHidden = (message == nil)

        if let action = action {
            actionButton.setTitle(action.label, for: .normal)
            actionButton.setTitleColor(.habPrimary, for: .normal)
            actionButton.titleLabel?.font = .habSubheadline
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }

        if let dismiss = dismissAction {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            dismissButton.setImage(
                UIImage(systemName: "xmark", withConfiguration: config),
                for: .normal
            )
            dismissButton.tintColor = .habForegroundSecondary
            dismissButton.accessibilityLabel = dismiss.label
            dismissButton.isHidden = false
        } else {
            dismissButton.isHidden = true
        }

        accessibilityLabel = [title, message].compactMap { $0 }.joined(separator: ". ")
        accessibilityTraits = .staticText
    }

    // MARK: - Actions

    @objc private func actionTapped() {
        action?.action()
    }

    @objc private func dismissTapped() {
        dismissAction?.action()
    }

    // MARK: - Theme

    @objc private func themeDidChange() { updateAppearance() }
}
