//
//  SAHABButtonDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABButtonDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let button = HABButton(style: .primary, size: .large, title: "Button")

    // MARK: - Setup

    override func setupComponent() {
        self.title = "HABButton"

        button.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    override func setupSettings() {
        // APPEARANCE
        addSectionHeader("Appearance")

        let styleSeg = makeSegmented(items: ["Prim", "Sec", "Ghost", "Destr"], selectedIndex: 0) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.button.style = .primary
                case 1:
                    self.button.style = .secondary
                case 2:
                    self.button.style = .ghost
                case 3:
                    self.button.style = .destructive
                default:
                    break
            }
        }
        addRow(label: "Style", control: styleSeg)

        let sizeSeg = makeSegmented(items: ["SM", "MD", "LG"], selectedIndex: 2) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.button.size = .small
                case 1:
                    self.button.size = .medium
                case 2:
                    self.button.size = .large
                default:
                    break
            }
        }
        addRow(label: "Size", control: sizeSeg)

        // OPTIONS
        addSectionHeader("Options")

        let iconSeg = makeSegmented(items: ["None", "Lead", "Trail", "Only"], selectedIndex: 0) { [weak self] index in
            guard let self else { return }
            let star = UIImage(systemName: "star.fill")
            switch index {
                case 0:
                    self.button.icon = nil
                    self.button.title = "Button"
                case 1:
                    self.button.icon = star
                    self.button.iconPosition = .leading
                    self.button.title = "Button"
                case 2:
                    self.button.icon = star
                    self.button.iconPosition = .trailing
                    self.button.title = "Button"
                case 3:
                    self.button.icon = star
                    self.button.title = nil
                default:
                    break
            }
        }
        addRow(label: "Icon", control: iconSeg)

        let enabledSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.button.isEnabled = isOn
        }
        addRow(label: "isEnabled", control: enabledSwitch)

        let loadingSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.button.isLoading = isOn
        }
        addRow(label: "isLoading", control: loadingSwitch)
    }
}
