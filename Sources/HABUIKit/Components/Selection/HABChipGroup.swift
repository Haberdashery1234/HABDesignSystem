//
//  HABChipGroup.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A group of selectable chips, for picking several options (weekdays, filters, tags) or
/// one option from a short list.
///
/// ## Overview
///
/// A weekday picker, one chip per day across the full width:
///
/// ```swift
/// let calendar = Calendar.current
/// let days = HABChipGroup(
///     items: calendar.veryShortWeekdaySymbols,          // S M T W T F S
///     selectedIndices: [1, 3, 5],
///     layout: .fillEqually
/// ) { selected in
///     draft.weekdays = selected
/// }
/// days.itemAccessibilityLabels = calendar.weekdaySymbols   // "Monday", not "M"
/// days.accessibilityLabel = "Days"
/// ```
///
/// Filters that wrap onto as many lines as they need:
///
/// ```swift
/// let filters = HABChipGroup(items: ["Taken", "Skipped", "Missed"], layout: .wrap)
/// ```
///
/// ## Selection
///
/// In ``SelectionMode/multiple`` mode each tap toggles a chip. In ``SelectionMode/single``
/// mode a tap selects that chip and clears the others. Set ``allowsEmptySelection`` to
/// `false` to keep at least one chip selected.
///
/// Setting ``selectedIndices`` in code doesn't call ``onSelectionChanged``. User changes
/// call it and also send `.valueChanged`.
///
/// ## VoiceOver
///
/// Each chip is a button that VoiceOver reads as "selected" when it's on. The group is a
/// semantic group: give it an `accessibilityLabel` ("Days") and VoiceOver announces it when
/// focus moves into the chips. Use ``itemAccessibilityLabels`` when the visible text is an
/// abbreviation.
///
/// ## Topics
///
/// ### Creating a Chip Group
/// - ``init(items:selectedIndices:selectionMode:layout:onSelectionChanged:)``
///
/// ### Items
/// - ``items``
/// - ``itemAccessibilityLabels``
///
/// ### Selection
/// - ``selectedIndices``
/// - ``selectionMode``
/// - ``SelectionMode``
/// - ``allowsEmptySelection``
///
/// ### Layout
/// - ``layout``
/// - ``Layout``
///
/// ### Responding to Changes
/// - ``onSelectionChanged``
public final class HABChipGroup: UIControl {
    // MARK: - Types

    /// How taps change the selection.
    public enum SelectionMode {
        /// One chip at a time.
        case single
        /// Any number of chips.
        case multiple
    }

    /// How the chips are arranged.
    public enum Layout {
        /// Chips sized to their text, wrapping onto new lines as needed.
        case wrap
        /// One row of equally wide chips that fills the width (e.g. weekdays).
        case fillEqually
    }

    // MARK: - Public Properties

    /// The chip titles. Changing them clears selections that no longer exist.
    public var items: [String] {
        didSet {
            rebuildChips()
            selectedIndices = selectedIndices.filteredIndexSet { items.indices.contains($0) }
        }
    }

    /// Optional VoiceOver labels, one per item, e.g. "Monday" for a chip showing "M".
    public var itemAccessibilityLabels: [String]? { didSet { updateChips() } }

    /// The indices of the selected chips.
    public var selectedIndices: IndexSet {
        didSet {
            let valid = selectedIndices.filteredIndexSet { items.indices.contains($0) }
            if valid != selectedIndices { selectedIndices = valid }
            updateChips()
        }
    }

    /// How taps change the selection. Defaults to `.multiple`.
    public var selectionMode: SelectionMode {
        didSet {
            if selectionMode == .single, selectedIndices.count > 1, let first = selectedIndices.first {
                selectedIndices = [first]
            }
        }
    }

    /// Whether the user can deselect the last selected chip. Defaults to `true`.
    public var allowsEmptySelection = true

    /// How the chips are arranged. Defaults to `.wrap`.
    public var layout: Layout { didSet { updateChips() } }

    /// Called with the new selection when the user taps a chip.
    public var onSelectionChanged: ((IndexSet) -> Void)?

    public override var isEnabled: Bool {
        didSet { chips.forEach { $0.isEnabled = isEnabled } }
    }

    // MARK: - Private

    private var chips: [HABChipButton] = []
    private var lastLayoutWidth: CGFloat = 0
    private var contentHeight: CGFloat = 0

    private static let spacing = HABSpacing.sm

    // MARK: - Init

    /// Creates a chip group.
    ///
    /// - Parameters:
    ///   - items: The chip titles.
    ///   - selectedIndices: The initially selected chips. Defaults to none.
    ///   - selectionMode: `.multiple` (default) or `.single`.
    ///   - layout: `.wrap` (default) or `.fillEqually`.
    ///   - onSelectionChanged: Called when the user changes the selection.
    public init(
        items: [String] = [],
        selectedIndices: IndexSet = [],
        selectionMode: SelectionMode = .multiple,
        layout: Layout = .wrap,
        onSelectionChanged: ((IndexSet) -> Void)? = nil
    ) {
        self.items = items
        var initial = selectedIndices.filteredIndexSet { items.indices.contains($0) }
        if selectionMode == .single, let first = initial.first { initial = [first] }
        self.selectedIndices = initial
        self.selectionMode = selectionMode
        self.layout = layout
        self.onSelectionChanged = onSelectionChanged
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityContainerType = .semanticGroup
        rebuildChips()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.updateChips()
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Chips

    private func rebuildChips() {
        chips.forEach { $0.removeFromSuperview() }
        chips = items.indices.map { index in
            let chip = HABChipButton()
            chip.tag = index
            chip.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            addSubview(chip)
            return chip
        }
        updateChips()
    }

    private func updateChips() {
        let font = UIFont.habSubheadline
        let horizontalInset = layout == .fillEqually ? HABSpacing.xs : HABSpacing.md - HABSpacing.xs
        for (index, chip) in chips.enumerated() where items.indices.contains(index) {
            chip.apply(
                title: items[index],
                font: font,
                horizontalInset: horizontalInset
            )
            chip.isSelected = selectedIndices.contains(index)
            chip.isEnabled = isEnabled
            chip.accessibilityLabel = itemAccessibilityLabels?.indices.contains(index) == true
                ? itemAccessibilityLabels?[index]
                : items[index]
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    @objc private func chipTapped(_ sender: UIButton) {
        let index = sender.tag
        guard items.indices.contains(index) else { return }

        var newSelection = selectedIndices
        if newSelection.contains(index) {
            guard allowsEmptySelection || newSelection.count > 1 else { return }
            newSelection.remove(index)
        } else if selectionMode == .single {
            newSelection = [index]
        } else {
            newSelection.insert(index)
        }
        guard newSelection != selectedIndices else { return }

        selectedIndices = newSelection
        sendActions(for: .valueChanged)
        onSelectionChanged?(newSelection)
    }

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : CGFloat.greatestFiniteMagnitude
        return CGSize(width: UIView.noIntrinsicMetric, height: frames(forWidth: width).height)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: frames(forWidth: size.width).height)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let result = frames(forWidth: bounds.width)
        for (chip, frame) in zip(chips, result.frames) {
            chip.frame = frame
        }
        if bounds.width != lastLayoutWidth || result.height != contentHeight {
            lastLayoutWidth = bounds.width
            contentHeight = result.height
            // The height depends on the width; tell Auto Layout now that the width is known.
            invalidateIntrinsicContentSize()
        }
    }

    /// Chip frames for a given width, mirrored for right-to-left layouts.
    private func frames(forWidth width: CGFloat) -> (frames: [CGRect], height: CGFloat) {
        guard !chips.isEmpty, width > 0 else { return ([], 0) }
        let spacing = Self.spacing
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        var frames: [CGRect] = []

        switch layout {
            case .fillEqually:
                let count = CGFloat(chips.count)
                let chipWidth = max(0, (width - spacing * (count - 1)) / count)
                let height = chips
                    .map { $0.sizeThatFits(CGSize(width: chipWidth, height: .greatestFiniteMagnitude)).height }
                    .max() ?? 0
                for index in chips.indices {
                    let x = CGFloat(index) * (chipWidth + spacing)
                    frames.append(CGRect(x: x, y: 0, width: chipWidth, height: height))
                }
                if isRTL { frames = frames.map { mirrored($0, in: width) } }
                return (frames, height)

            case .wrap:
                var x: CGFloat = 0
                var y: CGFloat = 0
                var rowHeight: CGFloat = 0
                for chip in chips {
                    var size = chip.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
                    size.width = min(size.width, width)
                    if x > 0, x + size.width > width {
                        x = 0
                        y += rowHeight + spacing
                        rowHeight = 0
                    }
                    frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
                    x += size.width + spacing
                    rowHeight = max(rowHeight, size.height)
                }
                if isRTL { frames = frames.map { mirrored($0, in: width) } }
                return (frames, y + rowHeight)
        }
    }

    private func mirrored(_ frame: CGRect, in width: CGFloat) -> CGRect {
        CGRect(x: width - frame.maxX, y: frame.minY, width: frame.width, height: frame.height)
    }

    // MARK: - Hit Testing

    /// Accept touches in the chips' 44pt touch areas even where they extend past the group.
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) { return true }
        return chips.contains { $0.point(inside: convert(point, to: $0), with: event) }
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateChips()
    }
}

// MARK: - HABChipButton

/// One chip: outlined when off, filled with the primary color when on.
final class HABChipButton: UIButton {
    private static let minimumHeight: CGFloat = 32

    init() {
        super.init(frame: .zero)
        configurationUpdateHandler = { button in
            guard var config = button.configuration else { return }
            let isOn = button.isSelected
            config.baseForegroundColor = isOn ? .habOnPrimary : .habForeground
            config.background.backgroundColor = isOn ? .habPrimary : .clear
            config.background.strokeColor = isOn ? .habPrimary : .habBorder
            config.background.strokeWidth = 1
            button.configuration = config
            button.alpha = button.isEnabled ? (button.isHighlighted ? 0.7 : 1) : 0.4
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(title: String, font: UIFont, horizontalInset: CGFloat) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.titleLineBreakMode = .byTruncatingTail
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(
            top: HABSpacing.xs + HABSpacing.xxs,
            leading: horizontalInset,
            bottom: HABSpacing.xs + HABSpacing.xxs,
            trailing: horizontalInset
        )
        // Capture the font rather than `self`: the transformer may run off the main actor.
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        config.titleAlignment = .center
        configuration = config
        setNeedsUpdateConfiguration()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fitted = super.sizeThatFits(size)
        return CGSize(width: fitted.width, height: max(fitted.height, Self.minimumHeight))
    }

    /// Accepts touches across at least 44×44pt.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.expandedToMinimum().contains(point)
    }
}
