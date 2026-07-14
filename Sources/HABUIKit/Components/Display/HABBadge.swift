//
//  HABBadge.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABBadge: UIView {
    // MARK: - Public Properties

    public var number: Int = 0 {
        didSet { updateAppearance() }
    }

    // MARK: - Private Subviews

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    // MARK: - Constraints

    private var widthConstraint: NSLayoutConstraint?

    // MARK: - Init

    public init() {
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
        addSubview(countLabel)

        // Fixed height of 18pt
        heightAnchor.constraint(equalToConstant: 18).isActive = true

        // Width: at least 18pt, grows with label content
        let minWidth = widthAnchor.constraint(greaterThanOrEqualToConstant: 18)
        minWidth.isActive = true

        // Width = label intrinsic width + 8pt horizontal padding, with low priority so
        // the greaterThanOrEqual can override it when label is wide
        widthConstraint = widthAnchor.constraint(equalTo: countLabel.widthAnchor, constant: 8)
        widthConstraint?.priority = UILayoutPriority(999)
        widthConstraint?.isActive = true

        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4)
        ])

        layer.cornerRadius = 9
        clipsToBounds = true
    }

    // MARK: - Appearance

    private func updateAppearance() {
        isHidden = number == 0

        countLabel.text = number > 99 ? "99+" : "\(number)"
        backgroundColor = .habDestructive
        countLabel.textColor = .white
        countLabel.font = .habCaption2

        layer.borderWidth = 1.5
        layer.borderColor = UIColor.habSurfaceElevated.cgColor

        // Accessibility
        isAccessibilityElement = true
        accessibilityLabel = "\(number) notifications"
        accessibilityTraits = [.staticText]
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
