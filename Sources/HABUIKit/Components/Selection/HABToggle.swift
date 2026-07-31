//
//  HABToggle.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A labeled switch control that integrates with the HAB design system theming.
///
/// `HABToggle` combines a `UISwitch` with an optional text label, providing a complete
/// toggle control that automatically responds to theme changes and supports flexible
/// label positioning.
///
/// ## Overview
///
/// Use `HABToggle` to allow users to turn an option on or off. The control pairs a standard
/// iOS switch with a text label, giving users clear context for what they're toggling.
///
/// The toggle supports:
/// - Optional text label with flexible positioning (leading or trailing)
/// - Enabled/disabled states with appropriate visual feedback
/// - Automatic theme updates for colors
/// - Proper accessibility support for VoiceOver
///
/// ## Creating a Toggle
///
/// Initialize a toggle with a label and optional callback:
///
/// ```swift
/// let toggle = HABToggle(
///     label: "Enable notifications",
///     isOn: true,
///     labelPosition: .trailing
/// ) { isOn in
///     print("Toggle is now: \(isOn)")
/// }
/// ```
///
/// ## Responding to Changes
///
/// Provide a closure to receive value changes:
///
/// ```swift
/// toggle.onValueChanged = { isOn in
///     // Handle the new state
///     updateSettings(notificationsEnabled: isOn)
/// }
/// ```
///
/// ## Topics
///
/// ### Creating a Toggle
/// - ``init(label:isOn:labelPosition:onValueChanged:)``
///
/// ### Configuring Appearance
/// - ``label``
/// - ``labelPosition``
/// - ``LabelPosition``
///
/// ### Managing State
/// - ``isOn``
/// - ``isEnabled``
///
/// ### Responding to Events
/// - ``onValueChanged``
public final class HABToggle: UIView {
    // MARK: - Enums

    /// The position of the label relative to the switch.
    public enum LabelPosition {
        /// Label appears before the switch (left in LTR, right in RTL).
        case leading
        
        /// Label appears after the switch (right in LTR, left in RTL).
        case trailing
    }

    // MARK: - Public Properties

    /// The text displayed next to the switch.
    ///
    /// Set to `nil` to hide the label and create a standalone switch.
    public var label: String? {
        didSet { updateAppearance() }
    }

    /// The position of the label relative to the switch.
    ///
    /// Changing this property rebuilds the layout immediately.
    public var labelPosition: LabelPosition = .trailing {
        didSet { setupLayout() }
    }

    /// A Boolean value that determines whether the toggle is in the on position.
    ///
    /// You can read this property to check the current state or set it to change
    /// the toggle position without animation.
    public var isOn: Bool {
        get { toggle.isOn }
        set { toggle.setOn(newValue, animated: false) }
    }

    /// A Boolean value that determines whether the toggle is enabled.
    ///
    /// When `false`, the toggle appears dimmed and doesn't respond to user interaction.
    public var isEnabled: Bool {
        get { toggle.isEnabled }
        set {
            toggle.isEnabled = newValue
            titleLabel.alpha = newValue ? 1.0 : 0.4
        }
    }

    /// A closure called when the toggle's value changes.
    ///
    /// The closure receives a single Boolean parameter indicating the new state (`true` for on, `false` for off).
    public var onValueChanged: ((Bool) -> Void)?

    // MARK: - Private Subviews

    private let toggle = UISwitch()
    private let titleLabel = UILabel()

    // MARK: - Private Layout

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Init

    /// Creates a new toggle control with the specified configuration.
    ///
    /// - Parameters:
    ///   - label: The text to display next to the switch. Defaults to `nil`.
    ///   - isOn: The initial state of the toggle. Defaults to `false`.
    ///   - labelPosition: The position of the label relative to the switch. Defaults to `.trailing`.
    ///   - onValueChanged: A closure called when the toggle's value changes. Defaults to `nil`.
    ///
    /// The toggle automatically registers for theme change notifications and updates
    /// its appearance when the active theme changes.
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
