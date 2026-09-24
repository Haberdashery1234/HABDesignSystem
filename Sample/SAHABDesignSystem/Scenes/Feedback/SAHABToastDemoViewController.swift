//
//  SAHABToastDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABToastDemoViewController: SAComponentDemoViewController {
    // MARK: - State

    private var currentStyle: HABToast.Style = .info
    private var currentDuration: TimeInterval = 3
    private var currentMessage: String = "Action completed."

    // MARK: - setupComponent

    override func setupComponent() {
        self.title = "HABToast"
        setPreviewHeight(160)

        let button = HABButton(style: .primary, size: .large, title: "Show Toast")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showToast), for: .touchUpInside)

        previewPanel.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    // MARK: - Action

    @objc private func showToast() {
        HABToast.show(message: currentMessage, style: currentStyle, duration: currentDuration, in: self.view)
    }

    // MARK: - setupSettings

    override func setupSettings() {
        addSectionHeader("Appearance")
        addRow(label: "Style", control: makeSegmented(items: ["Info", "Succ", "Warn", "Error"]) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.currentStyle = .info
                case 1:
                    self.currentStyle = .success
                case 2:
                    self.currentStyle = .warning
                default:
                    self.currentStyle = .error
            }
        })

        addSectionHeader("Behavior")
        addRow(label: "Duration", control: makeSegmented(items: ["2s", "3s", "5s"], selectedIndex: 1) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.currentDuration = 2
                case 1:
                    self.currentDuration = 3
                default:
                    self.currentDuration = 5
            }
        })

        addSectionHeader("Content")
        addRow(label: "Message", control: makeSegmented(items: ["Short", "Long"]) { [weak self] index in
            guard let self else { return }
            if index == 0 {
                self.currentMessage = "Action completed."
            } else {
                self.currentMessage = "Your changes have been saved and will sync shortly."
            }
        })
    }
}
