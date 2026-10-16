//
//  HABFormRow.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// One row in an ``HABFormSection``.
///
/// A row comes in two layouts:
///
/// - **Labeled** — a label at the leading edge and a control at the trailing edge
///   ("Starts … [date picker]"). Use it for date pickers, menu buttons and switches.
/// - **Full width** — one view that fills the row, for things that bring their own label,
///   such as ``HABToggle``, ``HABStepper``, ``HABTextField`` and ``HABChipGroup``.
///
/// ```swift
/// let startsRow = HABFormRow(label: "Starts", control: datePicker)
/// let reminderRow = HABFormRow(content: HABToggle(label: "Remind me", labelPosition: .leading))
/// ```
///
/// At accessibility text sizes a labeled row stacks the control under its label.
///
/// ## VoiceOver
///
/// In a labeled row the label names the control, so VoiceOver reads them together:
/// - A ``HABMenuButton`` gets the label as its ``HABMenuButton/name`` ("Repeat, Daily").
/// - Any other `UIControl` (a date picker, a switch, ``HABStepper``) gets it as its
///   accessibility label, unless you've already given it one.
/// - A view that isn't a control, such as a `UILabel` showing a value, is read with the
///   label as one element: "Dose, 10 mg".
///
/// Hide a row with `isHidden`; the section's dividers follow the visible rows.
public final class HABFormRow: UIView {
    // MARK: - Public Properties

    /// The label of a labeled row; `nil` for a full-width row.
    public var label: String? { didSet { updateAppearance() } }

    /// The control (labeled row) or content (full-width row).
    public let content: UIView

    // MARK: - Private

    private let titleLabel = UILabel()
    private let stack = UIStackView()
    private let isLabeled: Bool

    private static let minimumHeight: CGFloat = 44

    // MARK: - Init

    /// Creates a labeled row: label at the leading edge, control at the trailing edge.
    public init(label: String, control: UIView) {
        self.label = label
        self.content = control
        self.isLabeled = true
        super.init(frame: .zero)
        setup()
    }

    /// Creates a full-width row that shows `content` across the whole row.
    public init(content: UIView) {
        self.label = nil
        self.content = content
        self.isLabeled = false
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: HABSpacing.sm,
            leading: HABSpacing.md,
            bottom: HABSpacing.sm,
            trailing: HABSpacing.md
        )

        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        content.translatesAutoresizingMaskIntoConstraints = false

        stack.spacing = HABSpacing.sm
        stack.translatesAutoresizingMaskIntoConstraints = false
        if isLabeled {
            content.setContentHuggingPriority(.required, for: .horizontal)
            content.setContentCompressionResistancePriority(.required, for: .horizontal)
            stack.addArrangedSubview(titleLabel)
        }
        stack.addArrangedSubview(content)
        addSubview(stack)

        let margins = layoutMarginsGuide
        let minimumHeight = heightAnchor.constraint(greaterThanOrEqualToConstant: Self.minimumHeight)
        minimumHeight.priority = .required - 1
        // Hug the content when it's taller than the minimum; otherwise center it in the 44pt row
        // rather than stretching short content (a progress bar, a switch) to fill it.
        let hugContent = stack.topAnchor.constraint(equalTo: margins.topAnchor)
        hugContent.priority = .defaultLow - 1
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(greaterThanOrEqualTo: margins.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: margins.bottomAnchor),
            stack.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            hugContent,
            minimumHeight
        ])

        updateAxis()
        updateAppearance()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.updateAxis()
        }
    }

    // MARK: - Layout

    private func updateAxis() {
        guard isLabeled else {
            stack.axis = .vertical
            stack.alignment = .fill
            return
        }
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            stack.axis = .vertical
            stack.alignment = .leading
        } else {
            stack.axis = .horizontal
            stack.alignment = .center
        }
    }

    // MARK: - Appearance

    private func updateAppearance() {
        titleLabel.text = label
        titleLabel.font = .habBody
        titleLabel.textColor = .habForeground
        updateAccessibility()
    }

    /// The text this row gave its control, so a later label change can replace it.
    private var assignedControlLabel: String?

    /// A labeled row whose content isn't a control: read as one element, "Label, value".
    private var isReadOnlyValueRow: Bool {
        isLabeled && !(content is UIControl)
    }

    private func updateAccessibility() {
        guard isLabeled, let label else {
            isAccessibilityElement = false
            return
        }
        if let menuButton = content as? HABMenuButton {
            isAccessibilityElement = false
            titleLabel.isAccessibilityElement = false
            if menuButton.name?.isEmpty ?? true || menuButton.name == assignedControlLabel {
                menuButton.name = label
                assignedControlLabel = label
            }
        } else if content is UIControl {
            isAccessibilityElement = false
            titleLabel.isAccessibilityElement = false
            if content.accessibilityLabel?.isEmpty ?? true || content.accessibilityLabel == assignedControlLabel {
                content.accessibilityLabel = label
                assignedControlLabel = label
            }
        } else {
            isAccessibilityElement = true
            accessibilityLabel = label
        }
    }

    /// For a read-only value row, the content's current text (e.g. the value label's text).
    public override var accessibilityValue: String? {
        get { isReadOnlyValueRow ? content.accessibilityLabel : super.accessibilityValue }
        set { super.accessibilityValue = newValue }
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
