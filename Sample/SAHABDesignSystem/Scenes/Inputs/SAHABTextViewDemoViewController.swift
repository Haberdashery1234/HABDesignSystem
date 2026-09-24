//
//  SAHABTextViewDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABTextViewDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let textView = HABTextView(
        style: .outlined,
        topLabel: "Notes",
        placeholder: "Add a note\u{2026}",
        helperText: "Max 500 characters.",
        errorText: nil,
        isDisabled: false
    )

    // MARK: - Setup

    override func setupComponent() {
        self.title = "HABTextView"
        setPreviewHeight(280)

        textView.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.md),
            textView.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.md),
            textView.topAnchor.constraint(equalTo: previewPanel.topAnchor, constant: HABSpacing.md),
            textView.bottomAnchor.constraint(equalTo: previewPanel.bottomAnchor, constant: -HABSpacing.md)
        ])
    }

    override func setupSettings() {
        // APPEARANCE
        addSectionHeader("Appearance")

        let styleSeg = makeSegmented(items: ["Outlined", "Filled"], selectedIndex: 0) { [weak self] index in
            self?.textView.style = index == 0 ? .outlined : .filled
        }
        addRow(label: "Style", control: styleSeg)

        // LABELS
        addSectionHeader("Labels")

        let topLabelSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.textView.topLabel = isOn ? "Notes" : nil
        }
        addRow(label: "Top Label", control: topLabelSwitch)

        let helperSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.textView.helperText = isOn ? "Max 500 characters." : nil
        }
        addRow(label: "Helper Text", control: helperSwitch)

        let errorSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.textView.errorText = isOn ? "This field is required." : nil
        }
        addRow(label: "Error Text", control: errorSwitch)

        // STATE
        addSectionHeader("State")

        let disabledSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.textView.isDisabled = isOn
        }
        addRow(label: "Disabled", control: disabledSwitch)
    }
}
