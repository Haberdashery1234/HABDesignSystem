//
//  HABToast.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABToast: UIView {
    // MARK: - Style

    public enum Style {
        case info, success, warning, error
    }

    // MARK: - Static API

    public static func show(
        message: String,
        style: Style = .info,
        duration: TimeInterval = 3.0,
        in view: UIView
    ) {
        let toast = HABToast(message: message, style: style)
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)

        let bottomConstraint = toast.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: 100
        )

        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: HABSpacing.lg
            ),
            toast.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -HABSpacing.lg
            ),
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomConstraint
        ])

        view.layoutIfNeeded()

        bottomConstraint.constant = -HABSpacing.lg
        UIView.animate(
            withDuration: HABAnimation.Spring.gentle.duration,
            delay: 0,
            usingSpringWithDamping: 1.0 - HABAnimation.Spring.gentle.bounce,
            initialSpringVelocity: 0,
            options: HABAnimation.Curve.easeOut.options
        ) {
            view.layoutIfNeeded()
        }

        UIAccessibility.post(notification: .announcement, argument: message)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            toast.dismiss()
        }
    }

    // MARK: - Private Properties

    private let message: String
    private let style: Style
    private let messageLabel = UILabel()
    private let iconImageView = UIImageView()

    // MARK: - Init

    public init(message: String, style: Style = .info) {
        self.message = message
        self.style = style
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
        layer.cornerRadius = HABRadius.lg
        layer.masksToBounds = false
        HABShadow.medium.apply(to: layer)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .habSubheadline
        messageLabel.numberOfLines = 0

        addSubview(iconImageView)
        addSubview(messageLabel)

        let vertPad = CGFloat(HABSpacing.sm)
        let horizPad = CGFloat(HABSpacing.md)
        let iconSize: CGFloat = 20
        let gap = CGFloat(HABSpacing.sm)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizPad),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),

            messageLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: gap
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -horizPad
            ),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: vertPad),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vertPad)
        ])

        accessibilityLabel = message
        accessibilityTraits = .staticText
    }

    // MARK: - Appearance

    private func updateAppearance() {
        let iconName: String
        let tintColor: UIColor

        switch style {
            case .info:
                iconName = "info.circle.fill"
                tintColor = .habInfo
            case .success:
                iconName = "checkmark.circle.fill"
                tintColor = .habSuccess
            case .warning:
                iconName = "exclamationmark.triangle.fill"
                tintColor = .habWarning
            case .error:
                iconName = "xmark.circle.fill"
                tintColor = .habDestructive
        }

        backgroundColor = .habSurfaceElevated
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = tintColor
        messageLabel.text = message
        messageLabel.textColor = .habForeground
    }

    // MARK: - Dismiss

    private func dismiss() {
        UIView.animate(
            withDuration: HABAnimation.Duration.fast,
            animations: { self.alpha = 0 },
            completion: { _ in self.removeFromSuperview() }
        )
    }

    // MARK: - Theme

    @objc private func themeDidChange() { updateAppearance() }
}
