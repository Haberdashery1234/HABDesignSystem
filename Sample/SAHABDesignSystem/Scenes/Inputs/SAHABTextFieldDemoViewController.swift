//
//  SAHABTextFieldDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABTextFieldDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let field = HABTextField(
        style: .outlined,
        topLabel: "Email",
        helperText: nil,
        errorText: nil,
        leadingIcon: nil,
        trailingIcon: nil,
        trailingAction: nil,
        isDisabled: false
    )

    // MARK: - Setup

    override func setupComponent() {
        self.title = "HABTextField"
        setPreviewHeight(200)

        field.placeholder = "you@example.com"
        field.keyboardType = .emailAddress
        field.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(field)

        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.md),
            field.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.md),
            field.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    override func setupSettings() {
        // APPEARANCE
        addSectionHeader("Appearance")

        let styleSeg = makeSegmented(items: ["Outlined", "Filled"], selectedIndex: 0) { [weak self] index in
            self?.field.style = index == 0 ? .outlined : .filled
        }
        addRow(label: "Style", control: styleSeg)

        // LABELS
        addSectionHeader("Labels")

        let topLabelSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.field.topLabel = isOn ? "Email" : nil
        }
        addRow(label: "Top Label", control: topLabelSwitch)

        let helperSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.field.helperText = isOn ? "This is a helper message." : nil
        }
        addRow(label: "Helper Text", control: helperSwitch)

        let errorSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.field.errorText = isOn ? "Please enter a valid email." : nil
        }
        addRow(label: "Error Text", control: errorSwitch)

        // ICONS
        addSectionHeader("Icons")

        let leadingIconSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.field.leadingIcon = isOn ? UIImage(systemName: "envelope") : nil
        }
        addRow(label: "Leading Icon", control: leadingIconSwitch)

        let trailingActionSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            guard let self else { return }
            if isOn {
                self.field.trailingIcon = UIImage(systemName: "xmark.circle.fill")
                self.field.trailingAction = HABAccessibleAction(label: "Clear") { [weak self] in
                    self?.field.text = ""
                }
            } else {
                self.field.trailingIcon = nil
                self.field.trailingAction = nil
            }
        }
        addRow(label: "Trailing Action", control: trailingActionSwitch)

        // STATE
        addSectionHeader("State")

        let disabledSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.field.isDisabled = isOn
        }
        addRow(label: "Disabled", control: disabledSwitch)
    }
}
