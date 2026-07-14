//
//  HABLoadingView.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABLoadingView: UIView {
    // MARK: - Style

    public enum Style {
        case spinner
        case linear
    }

    // MARK: - Public Properties

    public var style: Style { didSet { updateAppearance() } }

    public var message: String? {
        didSet {
            updateAppearance()
            updateAccessibility()
        }
    }

    public var progress: Float? {
        didSet {
            updateProgress()
            updateAccessibility()
        }
    }

    // MARK: - Private Subviews

    private let spinner = UIActivityIndicatorView(style: .medium)
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let messageLabel = UILabel()

    // MARK: - Init

    public init(style: Style = .spinner, message: String? = nil) {
        self.style = style
        self.message = message
        super.init(frame: .zero)
        setupViews()
        updateAppearance()
        updateAccessibility()
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
        spinner.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        addSubview(spinner)
        addSubview(progressView)
        addSubview(messageLabel)

        let gap = CGFloat(HABSpacing.sm)

        NSLayoutConstraint.activate([
            // Spinner: centered horizontally and in upper region
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.topAnchor.constraint(equalTo: topAnchor),

            // Progress view: fills width, same top anchor
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: topAnchor),

            // Message label: below whichever indicator is active
            // We use both anchors, layout engine resolves via isHidden
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor
            ),
            messageLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor
            ),
            messageLabel.topAnchor.constraint(
                equalTo: spinner.bottomAnchor,
                constant: gap
            ),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Secondary constraint: messageLabel also tied below progressView
        // We let the spinner constraint drive layout; spinner and progressView share same top
        // so the message will be below both either way.
        let progressMessageConstraint = messageLabel.topAnchor.constraint(
            equalTo: progressView.bottomAnchor,
            constant: gap
        )
        progressMessageConstraint.priority = .defaultHigh
        progressMessageConstraint.isActive = true
    }

    // MARK: - Appearance

    private func updateAppearance() {
        let isSpinner = (style == .spinner)

        spinner.isHidden = !isSpinner
        progressView.isHidden = isSpinner

        messageLabel.isHidden = (message == nil)
        messageLabel.text = message
        messageLabel.font = .habFootnote
        messageLabel.textColor = .habForegroundSecondary
        messageLabel.textAlignment = .center

        spinner.color = .habPrimary
        progressView.progressTintColor = .habPrimary
        progressView.trackTintColor = .habBorder

        if isSpinner {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            updateProgress()
        }
    }

    // MARK: - Progress

    private func updateProgress() {
        guard style == .linear else { return }
        if let progress {
            progressView.setProgress(progress, animated: true)
        } else {
            progressView.progress = 0
        }
    }

    // MARK: - Accessibility

    private func updateAccessibility() {
        accessibilityLabel = message ?? "Loading"
        accessibilityTraits = .updatesFrequently
        if let progress {
            accessibilityValue = "\(Int(progress * 100)) percent"
        } else {
            accessibilityValue = nil
        }
    }

    // MARK: - Theme

    @objc private func themeDidChange() { updateAppearance() }
}
