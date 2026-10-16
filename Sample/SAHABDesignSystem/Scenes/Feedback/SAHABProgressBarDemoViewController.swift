//
//  SAHABProgressBarDemoViewController.swift
//  SAHABDesignSystem
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABProgressBarDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let bar = HABProgressBar(progress: 0.5)

    // MARK: - Setup

    override func setupComponent() {
        title = "HABProgressBar"
        setPreviewHeight(160)
        bar.accessibilityLabel = "Today's doses"
        previewPanel.addSubview(bar)

        NSLayoutConstraint.activate([
            bar.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor),
            bar.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.lg),
            bar.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.lg)
        ])
    }

    override func setupSettings() {
        addSectionHeader("Progress")

        let progressStepper = makeStepper(
            value: 50,
            min: 0,
            max: 100,
            step: 10,
            format: { "\(Int($0))%" },
            onChange: { [weak self] value in
                self?.bar.setProgress(Float(value / 100), animated: true)
            }
        )
        addRow(label: "Progress", control: progressStepper)

        addSectionHeader("Appearance")

        let tints: [HABProgressBar.Tint] = [.primary, .success, .warning, .destructive]
        let tintSeg = makeSegmented(items: ["Primary", "Success", "Warning", "Error"]) { [weak self] index in
            self?.bar.tint = tints[index]
        }
        addRow(label: "Tint", control: tintSeg)

        let heightStepper = makeStepper(
            value: 8,
            min: 4,
            max: 16,
            step: 2,
            format: { "\(Int($0)) pt" },
            onChange: { [weak self] value in
                self?.bar.barHeight = CGFloat(value)
            }
        )
        addRow(label: "Height", control: heightStepper)
    }
}
