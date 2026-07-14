//
//  HABToggle.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABToggle: UIView {
    // MARK: - Enums

    public enum LabelPosition {
        case leading
        case trailing
    }

    // MARK: - Public Properties

    public var label: String? {
        didSet { updateAppearance() }
    }

    public var labelPosition: LabelPosition = .trailing {
        didSet { setupLayout() }
    }

    public var isOn: Bool {
        get { toggle.isOn }
        set { toggle.setOn(newValue, animated: false) }
    }

    public var isEnabled: Bool {
        get { toggle.isEnabled }
        set {
            toggle.isEnabled = newValue
            titleLabel.alpha = newValue ? 1.0 : 0.4
        }
    }

    public var onValueChanged: ((Bool) -> Void)?

    // MARK: - Private Subviews

    private let toggle = UISwitch()
    private let titleLabel = UILabel()

    // MARK: - Private Layout

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Init

    public init(
        label: String? = nil,
        isOn: Bool = false,
        labelPosition: LabelPosition = .trailing,
        onValueChanged: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self.labelPosition = labelPosition
        self.onValueChanged = onValueChanged
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        setupSubviews()
        toggle.setOn(isOn, animated: false)
        setupLayout()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        updateAppearance()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }

    // MARK: - Setup

    private func setupSubviews() {
        titleLabel.font = .habBody
        titleLabel.textColor = .habForeground
        titleLabel.numberOfLines = 0

        toggle.addTarget(self, action: #selector(valueChanged), for: .valueChanged)

        // Accessibility: let toggle carry the full label + switch state
        isAccessibilityElement = false

        addSubview(toggle)
        addSubview(titleLabel)

        toggle.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()

        var constraints: [NSLayoutConstraint] = []

        // Both views vertically centered within self
        constraints += [
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggle.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            toggle.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ]

        switch labelPosition {
            case .trailing:
                // toggle --- gap --- titleLabel
                constraints += [
                    toggle.leadingAnchor.constraint(equalTo: leadingAnchor),
                    titleLabel.leadingAnchor.constraint(equalTo: toggle.trailingAnchor, constant: HABSpacing.sm),
                    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
                ]
            case .leading:
                // titleLabel --- gap --- toggle
                constraints += [
                    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                    toggle.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: HABSpacing.sm),
                    toggle.trailingAnchor.constraint(equalTo: trailingAnchor)
                ]
        }

        NSLayoutConstraint.activate(constraints)
        activeConstraints = constraints
    }

    // MARK: - Appearance

    private func updateAppearance() {
        toggle.onTintColor = .habPrimary
        titleLabel.text = label
        titleLabel.isHidden = (label == nil)
        toggle.accessibilityLabel = label
        titleLabel.textColor = .habForeground
    }

    // MARK: - Actions

    @objc private func valueChanged() {
        onValueChanged?(toggle.isOn)
    }
}
