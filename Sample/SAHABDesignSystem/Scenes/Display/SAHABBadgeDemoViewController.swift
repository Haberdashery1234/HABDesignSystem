//
//  SAHABBadgeDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABBadgeDemoViewController: SAComponentDemoViewController {
    private let badge = HABBadge()
    private let iconView = UIImageView(image: UIImage(systemName: "bell.fill"))

    override func setupComponent() {
        super.setupComponent()
        title = "HABBadge"
        setPreviewHeight(180)

        iconView.tintColor = .habForegroundSecondary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        badge.number = 3
        badge.translatesAutoresizingMaskIntoConstraints = false

        previewPanel.addSubview(iconView)
        previewPanel.addSubview(badge)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            iconView.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor),

            badge.topAnchor.constraint(equalTo: iconView.topAnchor, constant: -8),
            badge.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: -8)
        ])
    }

    override func setupSettings() {
        super.setupSettings()

        addSectionHeader("Count")

        addRow(label: "Count", control: makeStepper(value: 3, min: 0, max: 150) { [weak self] value in
            self?.badge.number = Int(value)
        })

        addRow(label: "Quick Set", control: makeSegmented(items: ["0", "1", "9", "99", "100"], selectedIndex: 0) { [weak self] index in
            self?.badge.number = [0, 1, 9, 99, 100][index]
        })
    }
}
