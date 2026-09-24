//
//  SAHABEmptyStateDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABEmptyStateDemoViewController: SAComponentDemoViewController {
    // MARK: - State

    private var iconEnabled: Bool = true
    private var currentSymbol: String = "tray"

    // MARK: - Component

    private let emptyState = HABEmptyState(
        title: "No Messages",
        message: "Your inbox is empty.",
        icon: UIImage(systemName: "tray"),
        action: nil
    )

    // MARK: - setupComponent

    override func setupComponent() {
        self.title = "HABEmptyState"
        setPreviewHeight(320)

        emptyState.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(emptyState)

        NSLayoutConstraint.activate([
            emptyState.topAnchor.constraint(equalTo: previewPanel.topAnchor),
            emptyState.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: previewPanel.bottomAnchor)
        ])
    }

    // MARK: - setupSettings

    override func setupSettings() {
        addSectionHeader("Content")
        addRow(label: "Icon", control: makeSwitch(isOn: true) { [weak self] isOn in
            guard let self else { return }
            self.iconEnabled = isOn
            self.emptyState.icon = isOn ? UIImage(systemName: self.currentSymbol) : nil
        })

        addRow(label: "Message", control: makeSwitch(isOn: true) { [weak self] isOn in
            guard let self else { return }
            self.emptyState.message = isOn ? "Your inbox is empty." : nil
        })

        addRow(label: "Action", control: makeSwitch(isOn: false) { [weak self] isOn in
            guard let self else { return }
            self.emptyState.action = isOn ? HABAccessibleAction(label: "Compose") {} : nil
        })

        addSectionHeader("Icon")
        addRow(label: "Symbol", control: makeSegmented(items: ["Tray", "Envelope", "Bell", "Star"]) { [weak self] index in
            guard let self else { return }
            let symbols = ["tray", "envelope", "bell", "star"]
            self.currentSymbol = symbols[index]
            if self.iconEnabled {
                self.emptyState.icon = UIImage(systemName: self.currentSymbol)
            }
        })
    }
}
