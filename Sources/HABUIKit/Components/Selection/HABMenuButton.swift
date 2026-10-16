//
//  HABMenuButton.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A pull-down button that shows the current value and opens a menu of options,
/// with a checkmark next to the selected one.
///
/// ## Overview
///
/// Use it for a setting with a handful of choices, typically at the trailing edge of a
/// labeled row:
///
/// ```swift
/// let repeatButton = HABMenuButton(
///     name: "Repeat",
///     titles: ["Never", "Daily", "Weekly", "Monthly"],
///     selectedIndex: 1
/// ) { index in
///     draft.repeatRule = RepeatRule.allCases[index]
/// }
/// let row = HABFormRow(label: "Repeat", control: repeatButton)
/// ```
///
/// ## VoiceOver
///
/// The button reads as "Name, value" ("Repeat, Daily, pop-up button"): ``name`` is the
/// accessibility label and the selected option is the value. ``HABFormRow`` and
/// ``HABListCell`` set ``name`` from their label when you leave it empty.
///
/// ## Topics
///
/// ### Creating a Menu Button
/// - ``init(name:options:selectedIndex:placeholder:onSelectionChanged:)``
/// - ``init(name:titles:selectedIndex:placeholder:onSelectionChanged:)``
///
/// ### Options and Selection
/// - ``Option``
/// - ``options``
/// - ``selectedIndex``
/// - ``selectedOption``
/// - ``placeholder``
///
/// ### Accessibility
/// - ``name``
///
/// ### Responding to Changes
/// - ``onSelectionChanged``
public final class HABMenuButton: UIButton {
    // MARK: - Types

    /// One choice in the menu.
    public struct Option: Equatable {
        /// The text shown in the menu and, when selected, on the button.
        public var title: String
        /// An optional image shown next to the title in the menu.
        public var image: UIImage?

        public init(_ title: String, image: UIImage? = nil) {
            self.title = title
            self.image = image
        }
    }

    // MARK: - Public Properties

    /// What the button sets, e.g. "Repeat". Used as the VoiceOver label; not shown on screen.
    public var name: String? { didSet { updateAccessibility() } }

    /// The choices in the menu. If the selected index no longer exists, the selection is cleared.
    public var options: [Option] {
        didSet {
            if let selectedIndex, !options.indices.contains(selectedIndex) {
                self.selectedIndex = nil
            } else {
                updateAll()
            }
        }
    }

    /// The index of the selected option, or `nil` for no selection.
    ///
    /// Setting this doesn't call ``onSelectionChanged``; only a choice the user makes does.
    /// Out-of-range values are treated as `nil`.
    public var selectedIndex: Int? {
        didSet {
            if let selectedIndex, !options.indices.contains(selectedIndex) {
                // Assigning inside didSet doesn't re-run the observer, so carry on below.
                self.selectedIndex = nil
            }
            updateAll()
        }
    }

    /// The selected option, if any.
    public var selectedOption: Option? {
        selectedIndex.map { options[$0] }
    }

    /// Text shown on the button when nothing is selected.
    public var placeholder: String? { didSet { updateAll() } }

    /// Called with the new index when the user picks a different option.
    public var onSelectionChanged: ((Int) -> Void)?

    // MARK: - Init

    /// Creates a menu button.
    ///
    /// - Parameters:
    ///   - name: What the button sets, for VoiceOver. Defaults to `nil`.
    ///   - options: The menu's choices.
    ///   - selectedIndex: The initially selected index, or `nil`.
    ///   - placeholder: Text shown when nothing is selected.
    ///   - onSelectionChanged: Called when the user picks a different option.
    public init(
        name: String? = nil,
        options: [Option] = [],
        selectedIndex: Int? = nil,
        placeholder: String? = nil,
        onSelectionChanged: ((Int) -> Void)? = nil
    ) {
        self.name = name
        self.options = options
        self.selectedIndex = selectedIndex.flatMap { options.indices.contains($0) ? $0 : nil }
        self.placeholder = placeholder
        self.onSelectionChanged = onSelectionChanged
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        showsMenuAsPrimaryAction = true
        setContentHuggingPriority(.required, for: .horizontal)
        configurationUpdateHandler = { button in
            button.alpha = button.state.contains(.disabled) ? 0.4 : 1
        }
        updateAll()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    /// Creates a menu button from plain titles.
    public convenience init(
        name: String? = nil,
        titles: [String],
        selectedIndex: Int? = nil,
        placeholder: String? = nil,
        onSelectionChanged: ((Int) -> Void)? = nil
    ) {
        self.init(
            name: name,
            options: titles.map { Option($0) },
            selectedIndex: selectedIndex,
            placeholder: placeholder,
            onSelectionChanged: onSelectionChanged
        )
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Hit Testing

    /// Accepts touches across at least 44×44pt.
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.expandedToMinimum().contains(point)
    }

    // MARK: - Selection

    /// Called when the user picks an option from the menu.
    private func userSelected(_ index: Int) {
        guard index != selectedIndex else { return }
        selectedIndex = index
        sendActions(for: .valueChanged)
        onSelectionChanged?(index)
    }

    // MARK: - Appearance

    private func updateAll() {
        updateMenu()
        updateAppearance()
        updateAccessibility()
    }

    private func updateMenu() {
        let actions = options.enumerated().map { index, option in
            UIAction(
                title: option.title,
                image: option.image,
                state: index == selectedIndex ? .on : .off
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.userSelected(index) }
            }
        }
        menu = UIMenu(options: .singleSelection, children: actions)
    }

    private func updateAppearance() {
        var config = UIButton.Configuration.plain()
        config.title = selectedOption?.title ?? placeholder
        config.baseForegroundColor = .habForegroundSecondary
        config.image = UIImage(systemName: "chevron.up.chevron.down")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(textStyle: .footnote)
            .applying(UIImage.SymbolConfiguration(weight: .semibold))
        config.imagePlacement = .trailing
        config.imagePadding = HABSpacing.xs
        config.contentInsets = NSDirectionalEdgeInsets(
            top: HABSpacing.xs, leading: HABSpacing.xs, bottom: HABSpacing.xs, trailing: 0
        )
        // Capture the font rather than `self`: the transformer may run off the main actor.
        let font = UIFont.habBody
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        config.titleLineBreakMode = .byTruncatingTail
        configuration = config
    }

    private func updateAccessibility() {
        accessibilityLabel = name
        accessibilityValue = selectedOption?.title ?? placeholder
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
