//
//  HABSegmentedControl.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABSegmentedControl: UIView {
    // MARK: - Public Properties

    public var items: [String] = [] {
        didSet { rebuildSegments() }
    }

    public var selectedIndex: Int {
        get { control.selectedSegmentIndex }
        set { control.selectedSegmentIndex = newValue }
    }

    public var onValueChanged: ((Int) -> Void)?

    // MARK: - Private Subviews

    private let control = UISegmentedControl()

    // MARK: - Init

    public init(
        items: [String] = [],
        selectedIndex: Int = 0,
        onValueChanged: ((Int) -> Void)? = nil
    ) {
        self.onValueChanged = onValueChanged
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        setupViews()
        self.items = items
        rebuildSegments()

        if !items.isEmpty {
            control.selectedSegmentIndex = min(selectedIndex, items.count - 1)
        }

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

    private func setupViews() {
        addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            control.topAnchor.constraint(equalTo: topAnchor),
            control.leadingAnchor.constraint(equalTo: leadingAnchor),
            control.trailingAnchor.constraint(equalTo: trailingAnchor),
            control.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    // MARK: - Segments

    private func rebuildSegments() {
        control.removeAllSegments()
        items.enumerated().forEach { index, title in
            control.insertSegment(withTitle: title, at: index, animated: false)
        }
        if !items.isEmpty {
            control.selectedSegmentIndex = 0
        }
        updateAppearance()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        control.selectedSegmentTintColor = .habPrimary
        control.backgroundColor = .habSurface

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.habForegroundSecondary,
            .font: UIFont.habSubheadline
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.habOnPrimary,
            .font: UIFont.habSubheadline
        ]

        control.setTitleTextAttributes(normalAttrs, for: .normal)
        control.setTitleTextAttributes(selectedAttrs, for: .selected)
    }

    // MARK: - Actions

    @objc private func valueChanged() {
        onValueChanged?(control.selectedSegmentIndex)
    }
}
