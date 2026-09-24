//
//  HABToast.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

public final class HABToast: UIView {
    // MARK: - Style

    public enum Style {
        case info, success, warning, error
    }

    // MARK: - Static API

    /// Shows a toast at the bottom of `view`.
    ///
    /// Toasts are queued per container view: if one is already showing in `view`,
    /// this one appears after it's dismissed, instead of overlapping it.
    /// Tapping a toast dismisses it early.
    public static func show(
        message: String,
        style: Style = .info,
        duration: TimeInterval = 3.0,
        in view: UIView
    ) {
        let request = Request(message: message, style: style, duration: duration)
        let key = ObjectIdentifier(view)
        if activeToasts[key]?.toast != nil {
            pendingRequests[key, default: []].append(request)
        } else {
            present(request, in: view)
        }
    }

    // MARK: - Queue

    private struct Request {
        let message: String
        let style: Style
        let duration: TimeInterval
    }

    private struct WeakToast {
        weak var toast: HABToast?
    }

    /// The toast currently on screen in each container view, keyed by that view.
    private static var activeToasts: [ObjectIdentifier: WeakToast] = [:]
    /// Toasts waiting for the current one in the same container to finish.
    private static var pendingRequests: [ObjectIdentifier: [Request]] = [:]

    private static func present(_ request: Request, in view: UIView) {
        let key = ObjectIdentifier(view)
        let toast = HABToast(message: request.message, style: request.style)
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.containerView = view
        view.addSubview(toast)
        activeToasts[key] = WeakToast(toast: toast)

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

        UIAccessibility.post(notification: .announcement, argument: request.message)

        DispatchQueue.main.asyncAfter(deadline: .now() + request.duration) { [weak toast] in
            toast?.dismiss()
        }
    }

    /// Called when a toast finishes dismissing: shows the next queued toast for that container.
    private static func toastDidDismiss(in view: UIView?) {
        guard let view else { return }
        let key = ObjectIdentifier(view)
        activeToasts[key] = nil
        guard var queue = pendingRequests[key], !queue.isEmpty else {
            pendingRequests[key] = nil
            return
        }
        let next = queue.removeFirst()
        pendingRequests[key] = queue.isEmpty ? nil : queue
        present(next, in: view)
    }

    // MARK: - Private Properties

    private let message: String
    private let style: Style
    private let messageLabel = UILabel()
    private let iconImageView = UIImageView()
    private weak var containerView: UIView?
    private var isDismissing = false

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

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc private func handleTap() {
        dismiss()
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
        // A tap and the timer can both call this; only dismiss once.
        guard !isDismissing else { return }
        isDismissing = true
        UIView.animate(
            withDuration: HABAnimation.Duration.fast,
            animations: { self.alpha = 0 },
            completion: { _ in
                let container = self.containerView
                self.removeFromSuperview()
                HABToast.toastDidDismiss(in: container)
            }
        )
    }

    // MARK: - Theme

    @objc private func themeDidChange() { updateAppearance() }
}
