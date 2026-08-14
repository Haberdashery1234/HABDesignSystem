//
//  ComponentDemoViewController.swift
//  HABUIKitSample
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

/// Base class for all per-component demo screens.
///
/// Provides a two-zone layout:
/// - Top: a surface-tinted preview wrapper containing a rounded `previewPanel`
///   where subclasses place and constrain their component.
/// - Bottom: a scrollable settings list built with `addSectionHeader(_:)` and
///   `addRow(label:control:)`, with factory methods for common controls.
///
/// Subclasses implement `setupComponent()` to add the component to `previewPanel`
/// and `setupSettings()` to populate the settings list.
open class ComponentDemoViewController: HABBaseViewController {
    // MARK: - Public

    /// The rounded card inside the preview area.
    /// Add and constrain your component here in `setupComponent()`.
    public let previewPanel = UIView()

    // MARK: - Private

    private let previewWrapper     = UIView()
    private let settingsScrollView = UIScrollView()
    private let settingsStack      = UIStackView()
    private var previewHeightConstraint: NSLayoutConstraint!

    // Tracked for theme updates
    private var sectionWrappers: [UIView]    = []
    private var internalDividers: [UIView]   = []
    private var sectionHeaderLabels: [UILabel] = []
    
    // Track dynamic setting views order for subclasses to manage
    public var dynamicSettingViewsOrder: [UIView] = []
    
    // Track dynamic setting views for subclasses to manage
    public var dynamicSettingViews: [UIView] = []

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        setupComponent()
        setupSettings()
    }

    // MARK: - Theme

    open override func themeDidChange() {
        super.themeDidChange()
        previewWrapper.backgroundColor = .habSurface
        previewPanel.backgroundColor = .habBackground
        sectionWrappers.forEach { $0.backgroundColor = .habBackgroundSecondary }
        internalDividers.forEach { $0.backgroundColor = .habBorderSubtle }
        sectionHeaderLabels.forEach { $0.textColor = .habForegroundSecondary }
        updateSettingsControlColors(in: settingsStack)
    }

    /// Walks the settings stack and re-tints UISwitch / UISegmentedControl to the active theme.
    private func updateSettingsControlColors(in view: UIView) {
        for subview in view.subviews {
            if let s = subview as? UISwitch {
                s.onTintColor = .habPrimary
            } else if let seg = subview as? UISegmentedControl {
                seg.selectedSegmentTintColor = .habPrimary
                seg.setTitleTextAttributes([.foregroundColor: UIColor.habForegroundSecondary], for: .normal)
                seg.setTitleTextAttributes([.foregroundColor: UIColor.habOnPrimary], for: .selected)
            } else if !subview.subviews.isEmpty {
                updateSettingsControlColors(in: subview)
            }
        }
    }

    // MARK: - Subclass Hooks

    /// Add your component to `previewPanel` and constrain it.
    open func setupComponent() {}

    /// Populate the settings list with `addSectionHeader` / `addRow` calls.
    open func setupSettings() {}

    // MARK: - Preview Height

    /// Override the preview pane height (default 220 pt).
    public func setPreviewHeight(_ height: CGFloat) {
        previewHeightConstraint.constant = height
    }

    // MARK: - Layout

    private func buildLayout() {
        previewWrapper.backgroundColor = .habSurface
        previewWrapper.translatesAutoresizingMaskIntoConstraints = false

        previewPanel.backgroundColor = .habBackground
        previewPanel.layer.cornerRadius = HABRadius.lg
        previewPanel.translatesAutoresizingMaskIntoConstraints = false
        previewWrapper.addSubview(previewPanel)

        let wrapperDivider = HABDivider()
        wrapperDivider.translatesAutoresizingMaskIntoConstraints = false

        settingsScrollView.keyboardDismissMode = .onDrag
        settingsScrollView.translatesAutoresizingMaskIntoConstraints = false

        settingsStack.axis = .vertical
        settingsStack.spacing = 0
        settingsStack.translatesAutoresizingMaskIntoConstraints = false
        settingsScrollView.addSubview(settingsStack)

        view.addSubview(previewWrapper)
        view.addSubview(wrapperDivider)
        view.addSubview(settingsScrollView)

        previewHeightConstraint = previewWrapper.heightAnchor.constraint(equalToConstant: 220)

        NSLayoutConstraint.activate([
            previewWrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewHeightConstraint,

            previewPanel.topAnchor.constraint(equalTo: previewWrapper.topAnchor, constant: HABSpacing.lg),
            previewPanel.leadingAnchor.constraint(equalTo: previewWrapper.leadingAnchor, constant: HABSpacing.lg),
            previewPanel.trailingAnchor.constraint(equalTo: previewWrapper.trailingAnchor, constant: -HABSpacing.lg),
            previewPanel.bottomAnchor.constraint(equalTo: previewWrapper.bottomAnchor, constant: -HABSpacing.lg),

            wrapperDivider.topAnchor.constraint(equalTo: previewWrapper.bottomAnchor),
            wrapperDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrapperDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            settingsScrollView.topAnchor.constraint(equalTo: wrapperDivider.bottomAnchor),
            settingsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            settingsStack.topAnchor.constraint(equalTo: settingsScrollView.topAnchor),
            settingsStack.leadingAnchor.constraint(equalTo: settingsScrollView.leadingAnchor),
            settingsStack.trailingAnchor.constraint(equalTo: settingsScrollView.trailingAnchor),
            settingsStack.bottomAnchor.constraint(equalTo: settingsScrollView.bottomAnchor),
            settingsStack.widthAnchor.constraint(equalTo: settingsScrollView.widthAnchor)
        ])
    }

    // MARK: - Settings Builders

    /// Adds a grey section header row (e.g. "APPEARANCE").
    public func addSectionHeader(_ text: String) {
        let wrapper = UIView()
        wrapper.backgroundColor = .habBackgroundSecondary
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        sectionWrappers.append(wrapper)

        let label = UILabel()
        label.text = text.uppercased()
        label.font = .habCaption1
        label.textColor = .habForegroundSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderLabels.append(label)
        wrapper.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: HABSpacing.xs),
            label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -HABSpacing.xs),
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: HABSpacing.md),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -HABSpacing.md)
        ])

        settingsStack.addArrangedSubview(wrapper)
        addInternalDivider()
    }

    /// Adds a settings row: left-aligned label, right-aligned control.
    public func addRow(label: String, control: UIView) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let lbl = HABLabel(textStyle: .body)
        lbl.text = label
        lbl.numberOfLines = 1
        lbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        lbl.translatesAutoresizingMaskIntoConstraints = false

        control.translatesAutoresizingMaskIntoConstraints = false
        control.setContentHuggingPriority(.required, for: .horizontal)
        control.setContentCompressionResistancePriority(.required, for: .horizontal)

        row.addSubview(lbl)
        row.addSubview(control)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),

            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: HABSpacing.md),
            lbl.trailingAnchor.constraint(lessThanOrEqualTo: control.leadingAnchor, constant: -HABSpacing.sm),

            control.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            control.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -HABSpacing.md)
        ])

        settingsStack.addArrangedSubview(row)
        addInternalDivider()
    }

    private func addInternalDivider() {
        let div = UIView()
        div.backgroundColor = .habBorderSubtle
        div.translatesAutoresizingMaskIntoConstraints = false
        div.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        internalDividers.append(div)
        settingsStack.addArrangedSubview(div)
    }

    // MARK: - Dynamic Settings Management
    
    /// Removes all tracked dynamic setting views.
    /// Subclasses can use this to rebuild dynamic settings when state changes.
    public func removeDynamicSettings() {
        for view in dynamicSettingViews {
            settingsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
            
            // Clean up from tracking arrays
            if let index = sectionWrappers.firstIndex(of: view) {
                sectionWrappers.remove(at: index)
            }
            if let index = internalDividers.firstIndex(of: view) {
                internalDividers.remove(at: index)
            }
        }
        dynamicSettingViews.removeAll()
    }
    
    /// Returns the current count of views in the settings stack.
    /// Use this to track views: capture count before adding, then use settingsStackViews(from:) after.
    public func settingsStackViewCount() -> Int {
        return settingsStack.arrangedSubviews.count
    }
    
    /// Returns views added to the settings stack since the given index.
    /// Useful for capturing newly added dynamic views to track in dynamicSettingViews.
    public func settingsStackViews(from startIndex: Int) -> [UIView] {
        let endIndex = settingsStack.arrangedSubviews.count
        guard startIndex < endIndex else { return [] }
        return Array(settingsStack.arrangedSubviews[startIndex..<endIndex])
    }
    
    // MARK: - Control Factories

    /// A `UISwitch` bound to a change closure.
    public func makeSwitch(isOn: Bool = false, onChange: @escaping (Bool) -> Void) -> UISwitch {
        let newSwitch = UISwitch()
        newSwitch.isOn = isOn
        newSwitch.onTintColor = .habPrimary
        newSwitch.addAction(UIAction { [weak newSwitch] _ in onChange(newSwitch?.isOn ?? false) }, for: .valueChanged)
        return newSwitch
    }

    /// A `UISegmentedControl` bound to a change closure.
    public func makeSegmented(items: [String], selectedIndex: Int = 0, onChange: @escaping (Int) -> Void) -> UISegmentedControl {
        let seg = UISegmentedControl(items: items)
        seg.selectedSegmentIndex = selectedIndex
        seg.selectedSegmentTintColor = .habPrimary
        seg.setTitleTextAttributes([.foregroundColor: UIColor.habForegroundSecondary], for: .normal)
        seg.setTitleTextAttributes([.foregroundColor: UIColor.habOnPrimary], for: .selected)
        seg.addAction(UIAction { [weak seg] _ in onChange(seg?.selectedSegmentIndex ?? 0) }, for: .valueChanged)
        return seg
    }

    /// A labeled stepper (`[value label] [stepper]`) bound to a change closure.
    public func makeStepper(
        value: Double,
        min: Double,
        max: Double,
        step: Double = 1,
        format: @escaping (Double) -> String = { "\(Int($0))" },
        onChange: @escaping (Double) -> Void
    ) -> UIView {
        let valueLabel = UILabel()
        valueLabel.font = .habBody
        valueLabel.textColor = .habForegroundSecondary
        valueLabel.text = format(value)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stepper = UIStepper()
        stepper.minimumValue = min
        stepper.maximumValue = max
        stepper.stepValue = step
        stepper.value = value
        stepper.addAction(UIAction { [weak stepper, weak valueLabel] _ in
            guard let value = stepper?.value else { return }
            valueLabel?.text = format(value)
            onChange(value)
        }, for: .valueChanged)

        let container = UIStackView(arrangedSubviews: [valueLabel, stepper])
        container.axis = .horizontal
        container.spacing = HABSpacing.sm
        container.alignment = .center
        return container
    }
}
