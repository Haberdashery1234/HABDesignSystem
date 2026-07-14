//
//  HABCard.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABCard: UIView {
    // MARK: - Enums

    public enum Style {
        case elevated
        case outlined
        case flat
    }

    // MARK: - Public Properties

    public var style: Style {
        didSet { updateAppearance() }
    }

    // MARK: - Init

    public init(style: Style = .elevated) {
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        
        // Register for trait changes (iOS 17+)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.updateAppearance()
        }
        
        updateAppearance()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        layer.cornerRadius = HABRadius.lg
        backgroundColor = .habSurface

        switch style {
            case .elevated:
                layer.borderWidth = 0
                layer.borderColor = UIColor.clear.cgColor
                HABShadow.low.apply(to: layer)
            case .outlined:
                layer.borderWidth = 1
                layer.borderColor = UIColor.habBorder.cgColor
                HABShadowStyle.clear(layer)
            case .flat:
                layer.borderWidth = 0
                layer.borderColor = UIColor.clear.cgColor
                HABShadowStyle.clear(layer)
        }
    }
}
