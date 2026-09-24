//
//  SAHABToggleDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABToggleDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let toggle = HABToggle(
        label: "Enable notifications",
        isOn: false,
        labelPosition: .trailing
    )

    // MARK: - Setup

    override func setupComponent() {
        self.title = "HABToggle"
        setPreviewHeight(180)

        toggle.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(toggle)

        NSLayoutConstraint.activate([
            toggle.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            toggle.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    override func setupSettings() {
        // APPEARANCE
        addSectionHeader("Appearance")

        let positionSeg = makeSegmented(items: ["Lead", "Trail"], selectedIndex: 1) { [weak self] index in
            self?.toggle.labelPosition = index == 0 ? .leading : .trailing
        }
        addRow(label: "Label Position", control: positionSeg)

        // OPTIONS
        addSectionHeader("Options")

        let showLabelSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.toggle.label = isOn ? "Enable notifications" : nil
        }
        addRow(label: "Show Label", control: showLabelSwitch)

        let isOnSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.toggle.isOn = isOn
        }
        addRow(label: "Is On", control: isOnSwitch)

        let enabledSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.toggle.isEnabled = isOn
        }
        addRow(label: "Enabled", control: enabledSwitch)
    }
}
