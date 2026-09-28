//
//  HABBadge.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

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

        // At least 18pt tall; grows with the label at larger Dynamic Type sizes.
        heightAnchor.constraint(greaterThanOrEqualToConstant: 18).isActive = true
        countLabel.adjustsFontForContentSizeCategory = true

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
            countLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 1),
            countLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -1),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4)
        ])

        clipsToBounds = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Stay a capsule as the height grows with Dynamic Type.
        layer.cornerRadius = bounds.height / 2
    }

    // MARK: - Appearance

    private func updateAppearance() {
        isHidden = number == 0

        countLabel.text = number > 99 ? "99+" : "\(number)"
        backgroundColor = .habDestructive
        countLabel.textColor = .habOnDestructive
        countLabel.font = .habCaption2

        layer.borderWidth = 1.5
        layer.borderColor = UIColor.habSurfaceElevated.cgColor

        // Accessibility
        isAccessibilityElement = true
        accessibilityLabel = HABStrings.notifications(number)
        accessibilityTraits = [.staticText]
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
