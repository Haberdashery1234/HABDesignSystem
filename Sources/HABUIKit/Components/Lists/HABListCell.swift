//
//  HABListCell.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A themed table view row: title, optional subtitle, optional trailing value,
/// optional leading icon, and an accessory.
///
/// ## Overview
///
/// Register the cell once, then configure it in `cellForRowAt`:
///
/// ```swift
/// tableView.register(HABListCell.self, forCellReuseIdentifier: HABListCell.reuseIdentifier)
///
/// let cell = tableView.dequeueReusableCell(
///     withIdentifier: HABListCell.reuseIdentifier, for: indexPath
/// ) as! HABListCell
/// cell.configure(
///     title: "Notifications",
///     value: "On",
///     icon: UIImage(systemName: "bell"),
///     accessory: .chevron
/// )
/// ```
///
/// ## Styles
///
/// - ``Style/default``: a selectable row. Pair it with ``Accessory/chevron`` for
///   navigation or ``Accessory/checkmark`` for a choice in a list.
/// - ``Style/value``: a read-only row that shows a label and its value
///   ("RxNorm Release … 03-Aug-2026"). It doesn't highlight when tapped.
/// - ``Style/action(_:)``: a button-like row ("Sign Out", "Delete Medication") in the
///   primary or destructive color. Set ``isEnabled`` to `false` to disable it.
///
/// ## Background
///
/// The row draws on `habSurface` and switches to a slightly darker (or lighter, in dark
/// mode) surface while it's highlighted or selected, so the pressed state stays visible
/// with every theme. You don't need to set `backgroundColor` or `selectedBackgroundView`.
///
/// ## VoiceOver and UI tests
///
/// The row is a single accessibility element:
/// - **label**: the title, followed by the subtitle ("Lisinopril, 10 mg tablet")
/// - **value**: the trailing value, followed by a custom accessory's own label
/// - **traits**: `.button` for rows with a chevron, checkmark or action style,
///   `.selected` for a checkmark, and `.notEnabled` when disabled
///
/// Set `accessibilityIdentifier` on the cell and query it in UI tests:
///
/// ```swift
/// let row = app.cells["settings.notifications"]
/// XCTAssertEqual(row.label, "Notifications")
/// XCTAssertEqual(row.value as? String, "On")
/// ```
///
/// Setting `accessibilityLabel` or `accessibilityValue` yourself overrides the generated
/// text; set it back to `nil` to return to the default.
///
/// When the custom accessory is a control (a `UISwitch`, ``HABMenuButton`` and so on),
/// the row stops being a single element so VoiceOver can still reach the control. The
/// title (with the subtitle) and the value are then read as separate elements, and the
/// control is labeled with the title unless it already has a label.
///
/// ## Topics
///
/// ### Configuring the Row
/// - ``configure(title:subtitle:value:icon:accessory:style:)``
/// - ``title``
/// - ``subtitle``
/// - ``value``
/// - ``icon``
/// - ``iconTintColor``
/// - ``accessory``
/// - ``rowStyle``
/// - ``isEnabled``
public final class HABListCell: UITableViewCell {
    // MARK: - Types

    /// Reuse identifier to register and dequeue the cell with.
    public static let reuseIdentifier = "HABListCell"

    /// How the row looks and behaves.
    public enum Style: Equatable {
        /// A selectable row.
        case `default`
        /// A read-only label and value. Doesn't highlight when tapped.
        case value
        /// A button-like row with its title in the role's color.
        case action(ActionRole)
    }

    /// The color role of an ``Style/action(_:)`` row.
    public enum ActionRole: Equatable {
        /// The primary brand color.
        case primary
        /// The destructive color, for actions like delete and sign out.
        case destructive
    }

    /// The view shown at the trailing edge of the row.
    public enum Accessory {
        /// No accessory.
        case none
        /// A forward chevron, for rows that navigate somewhere.
        case chevron
        /// A checkmark, for the chosen option in a list.
        case checkmark
        /// Any view, such as an ``HABTag``, a ``HABBadge`` or a `UISwitch`.
        case custom(UIView)
    }

    // MARK: - Public Properties

    /// The main text.
    public var title: String? { didSet { setNeedsContentUpdate() } }

    /// Secondary text shown under the title.
    public var subtitle: String? { didSet { setNeedsContentUpdate() } }

    /// Text shown at the trailing edge, before the accessory.
    public var value: String? { didSet { setNeedsContentUpdate() } }

    /// An image shown at the leading edge. SF Symbols are sized to the body text.
    public var icon: UIImage? { didSet { setNeedsContentUpdate() } }

    /// The icon's tint. `nil` uses the primary color, or the action color for action rows.
    public var iconTintColor: UIColor? { didSet { setNeedsContentUpdate() } }

    /// The view shown at the trailing edge.
    public var accessory: Accessory = .none { didSet { setNeedsContentUpdate() } }

    /// The row's style. Named `rowStyle` to avoid confusion with `UITableViewCell.CellStyle`.
    public var rowStyle: Style = .default { didSet { setNeedsContentUpdate() } }

    /// Whether the row responds to taps. A disabled row dims its content and
    /// reports itself as "dimmed" to VoiceOver.
    public var isEnabled: Bool = true { didSet { setNeedsContentUpdate() } }

    // MARK: - Private Subviews

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronView = UIImageView()
    private let checkmarkView = UIImageView()

    private let textStack = UIStackView()
    /// Holds the text and the value. Horizontal normally; vertical at accessibility text sizes.
    private let labelsStack = UIStackView()
    private let accessoryStack = UIStackView()
    private let mainStack = UIStackView()

    private var customAccessoryView: UIView?
    private var customAccessibilityLabel: String?
    private var customAccessibilityValue: String?

    /// While `true`, property changes don't each rebuild the row; one update runs at the end.
    private var isBatchingUpdates = false

    private static let iconSize: CGFloat = 28
    private static let minimumHeight: CGFloat = 44

    // MARK: - Init

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        updateContentSizeLayout()
        updateContent()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.updateContentSizeLayout()
        }
    }

    /// Creates a cell outside a table view, e.g. for tests or a static layout.
    public convenience init() {
        self.init(style: .default, reuseIdentifier: Self.reuseIdentifier)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Sets every part of the row at once. Parameters you leave out are reset to their defaults,
    /// which makes this safe to call on a reused cell.
    public func configure(
        title: String?,
        subtitle: String? = nil,
        value: String? = nil,
        icon: UIImage? = nil,
        accessory: Accessory = .none,
        style: Style = .default
    ) {
        isBatchingUpdates = true
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.icon = icon
        self.accessory = accessory
        self.rowStyle = style
        isBatchingUpdates = false
        updateContent()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        isBatchingUpdates = true
        title = nil
        subtitle = nil
        value = nil
        icon = nil
        iconTintColor = nil
        accessory = .none
        rowStyle = .default
        isEnabled = true
        customAccessibilityLabel = nil
        customAccessibilityValue = nil
        accessibilityIdentifier = nil
        isBatchingUpdates = false
        updateContent()
    }

    // MARK: - Setup

    private func setupViews() {
        automaticallyUpdatesBackgroundConfiguration = false
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: HABSpacing.sm + HABSpacing.xxs,
            leading: HABSpacing.md,
            bottom: HABSpacing.sm + HABSpacing.xxs,
            trailing: HABSpacing.md
        )
        configureSubviews()
        configureStackViews()
        setupConstraints()
    }

    private func configureSubviews() {
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
        iconView.isAccessibilityElement = false

        [titleLabel, subtitleLabel, valueLabel].forEach {
            $0.numberOfLines = 0
            $0.adjustsFontForContentSizeCategory = true
        }

        chevronView.image = UIImage(systemName: "chevron.forward")
        chevronView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote)
            .applying(UIImage.SymbolConfiguration(weight: .semibold))
        chevronView.contentMode = .center
        chevronView.isAccessibilityElement = false

        checkmarkView.image = UIImage(systemName: "checkmark")
        checkmarkView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
            .applying(UIImage.SymbolConfiguration(weight: .semibold))
        checkmarkView.contentMode = .center
        checkmarkView.isAccessibilityElement = false
    }

    private func configureStackViews() {
        textStack.axis = .vertical
        textStack.spacing = HABSpacing.xxs
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        labelsStack.spacing = HABSpacing.sm
        labelsStack.addArrangedSubview(textStack)
        labelsStack.addArrangedSubview(valueLabel)

        accessoryStack.axis = .horizontal
        accessoryStack.alignment = .center
        accessoryStack.addArrangedSubview(chevronView)
        accessoryStack.addArrangedSubview(checkmarkView)

        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = HABSpacing.sm + HABSpacing.xs
        mainStack.addArrangedSubview(iconView)
        mainStack.addArrangedSubview(labelsStack)
        mainStack.addArrangedSubview(accessoryStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
    }

    private func setupConstraints() {
        titleLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        [iconView, accessoryStack, chevronView, checkmarkView].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        let margins = contentView.layoutMarginsGuide
        let minimumHeight = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: Self.minimumHeight)
        minimumHeight.priority = .required - 1
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: margins.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            minimumHeight,
            iconView.widthAnchor.constraint(equalToConstant: Self.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: Self.iconSize)
        ])
    }

    // MARK: - Content

    private func setNeedsContentUpdate() {
        guard !isBatchingUpdates else { return }
        updateContent()
    }

    private func updateContent() {
        updateLabels()
        updateAccessory()
        updateFontsAndColors()
        updateAccessibility()
        selectionStyle = isHighlightable ? .default : .none
        isUserInteractionEnabled = isEnabled
        setNeedsUpdateConfiguration()
        setNeedsLayout()
    }

    private func updateLabels() {
        titleLabel.text = title
        titleLabel.isHidden = title?.isEmpty ?? true
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true
        valueLabel.text = value
        valueLabel.isHidden = value?.isEmpty ?? true
        iconView.image = icon
        iconView.isHidden = icon == nil
    }

    private func updateAccessory() {
        chevronView.isHidden = true
        checkmarkView.isHidden = true

        var newCustomView: UIView?
        switch accessory {
            case .none:
                break
            case .chevron:
                chevronView.isHidden = false
            case .checkmark:
                checkmarkView.isHidden = false
            case .custom(let view):
                newCustomView = view
        }

        if customAccessoryView !== newCustomView {
            customAccessoryView?.removeFromSuperview()
            customAccessoryView = newCustomView
            if let newCustomView {
                newCustomView.translatesAutoresizingMaskIntoConstraints = false
                newCustomView.setContentHuggingPriority(.required, for: .horizontal)
                newCustomView.setContentCompressionResistancePriority(.required, for: .horizontal)
                accessoryStack.addArrangedSubview(newCustomView)
            }
        }
        accessoryStack.isHidden = accessoryStack.arrangedSubviews.allSatisfy { $0.isHidden }
    }

    private func updateFontsAndColors() {
        titleLabel.font = .habBody
        subtitleLabel.font = .habSubheadline
        valueLabel.font = .habBody

        let titleColor: UIColor
        let iconColor: UIColor
        switch rowStyle {
            case .default, .value:
                titleColor = .habForeground
                iconColor = iconTintColor ?? .habPrimary
            case .action(let role):
                let roleColor: UIColor = role == .destructive ? .habDestructive : .habPrimary
                titleColor = roleColor
                iconColor = iconTintColor ?? roleColor
        }

        titleLabel.textColor = isEnabled ? titleColor : .habForegroundDisabled
        subtitleLabel.textColor = isEnabled ? .habForegroundSecondary : .habForegroundDisabled
        valueLabel.textColor = isEnabled ? .habForegroundSecondary : .habForegroundDisabled
        iconView.tintColor = isEnabled ? iconColor : .habForegroundDisabled
        chevronView.tintColor = .habForegroundTertiary
        checkmarkView.tintColor = isEnabled ? .habPrimary : .habForegroundDisabled
    }

    /// Value rows and disabled rows don't show a pressed state.
    private var isHighlightable: Bool {
        isEnabled && rowStyle != .value
    }

    // MARK: - Dynamic Type

    private func updateContentSizeLayout() {
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            // Stack the value under the title so neither gets squeezed to a sliver.
            labelsStack.axis = .vertical
            labelsStack.alignment = .leading
            valueLabel.textAlignment = .natural
        } else {
            labelsStack.axis = .horizontal
            labelsStack.alignment = .center
            valueLabel.textAlignment = effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
        }
    }

    // MARK: - Background

    public override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        var background = UIBackgroundConfiguration.clear()
        let isPressed = (state.isHighlighted || state.isSelected) && isHighlightable
        background.backgroundColor = isPressed ? .habSurfaceHighlighted : .habSurface
        backgroundConfiguration = background
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Start the separator under the text, past the icon, the way system rows do.
        let textFrame = labelsStack.convert(labelsStack.bounds, to: self)
        let leadingInset = effectiveUserInterfaceLayoutDirection == .rightToLeft
            ? bounds.width - textFrame.maxX
            : textFrame.minX
        if leadingInset > 0, abs(separatorInset.left - leadingInset) > 0.5 {
            separatorInset.left = leadingInset
        }
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateFontsAndColors()
        setNeedsUpdateConfiguration()
    }
}

// MARK: - Accessibility

extension HABListCell {
    private var hasInteractiveAccessory: Bool {
        customAccessoryView is UIControl
    }

    private var defaultAccessibilityLabel: String? {
        let parts = [title, subtitle].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    private var defaultAccessibilityValue: String? {
        var parts: [String] = []
        if let value, !value.isEmpty { parts.append(value) }
        if !hasInteractiveAccessory,
           let accessoryLabel = customAccessoryView?.accessibilityLabel,
           !accessoryLabel.isEmpty {
            parts.append(accessoryLabel)
        }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    public override var accessibilityLabel: String? {
        get { customAccessibilityLabel ?? defaultAccessibilityLabel }
        set { customAccessibilityLabel = newValue }
    }

    public override var accessibilityValue: String? {
        get { customAccessibilityValue ?? defaultAccessibilityValue }
        set { customAccessibilityValue = newValue }
    }

    func updateAccessibility() {
        accessibilityTraits = computeAccessibilityTraits()
        if hasInteractiveAccessory, let control = customAccessoryView {
            configureAccessibilityForInteractiveAccessory(control)
        } else {
            isAccessibilityElement = true
            accessibilityElements = nil
            titleLabel.accessibilityLabel = nil
        }
    }

    private func computeAccessibilityTraits() -> UIAccessibilityTraits {
        var traits: UIAccessibilityTraits = []
        switch rowStyle {
            case .action:
                traits.insert(.button)
            case .value:
                traits.insert(.staticText)
            case .default:
                if case .chevron = accessory { traits.insert(.button) }
                if case .checkmark = accessory { traits.insert(.button) }
        }
        if case .checkmark = accessory { traits.insert(.selected) }
        if !isEnabled { traits.insert(.notEnabled) }
        return traits
    }

    private func configureAccessibilityForInteractiveAccessory(_ control: UIView) {
        isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityLabel = defaultAccessibilityLabel
        subtitleLabel.isAccessibilityElement = false
        valueLabel.isAccessibilityElement = !valueLabel.isHidden
        if let menuButton = control as? HABMenuButton {
            if menuButton.name?.isEmpty ?? true { menuButton.name = title }
        } else if control.accessibilityLabel?.isEmpty ?? true {
            control.accessibilityLabel = title
        }
        accessibilityElements = [titleLabel, valueLabel, control].filter { !$0.isHidden }
    }
}
