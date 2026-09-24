//
//  SAHABSegmentedControlDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABSegmentedControlDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let control = HABSegmentedControl(
        items: ["Day", "Week", "Month"],
        selectedIndex: 0
    )

    // MARK: - Item Sets

    private let twoItems   = ["On", "Off"]
    private let threeItems = ["Day", "Week", "Month"]
    private let fourItems  = ["XS", "SM", "MD", "LG"]

    // MARK: - Setup

    override func setupComponent() {
        self.title = "HABSegmentedControl"
        setPreviewHeight(160)

        control.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(control)

        NSLayoutConstraint.activate([
            control.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.md),
            control.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.md),
            control.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    override func setupSettings() {
        // OPTIONS
        addSectionHeader("Options")

        let itemsSeg = makeSegmented(items: ["2 items", "3 items", "4 items"], selectedIndex: 1) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.control.items = self.twoItems
                case 1:
                    self.control.items = self.threeItems
                case 2:
                    self.control.items = self.fourItems
                default:
                    break
            }
        }
        addRow(label: "Items", control: itemsSeg)

        let defaultSeg = makeSegmented(items: ["0", "1", "2", "3"], selectedIndex: 0) { [weak self] index in
            guard let self else { return }
            self.control.selectedIndex = min(index, self.control.items.count - 1)
        }
        addRow(label: "Default", control: defaultSeg)
    }
}
