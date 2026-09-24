//
//  SAHABTagDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABTagDemoViewController: SAComponentDemoViewController {
    private var tag = HABTag(label: "Status", style: .filled, color: .primary)

    override func setupComponent() {
        super.setupComponent()
        title = "HABTag"

        tag.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(tag)

        NSLayoutConstraint.activate([
            tag.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            tag.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    override func setupSettings() {
        super.setupSettings()

        addSectionHeader("Appearance")

        addRow(label: "Style", control: makeSegmented(items: ["Fill", "Outline", "Subtle"], selectedIndex: 0) { [weak self] index in
            self?.tag.style = [HABTag.Style.filled, .outlined, .subtle][index]
        })

        addRow(label: "Color", control: makeSegmented(items: ["Pri", "Succ", "Warn", "Err", "Neut"], selectedIndex: 0) { [weak self] index in
            self?.tag.color = [HABTag.Color.primary, .success, .warning, .destructive, .neutral][index]
        })

        addSectionHeader("Options")

        addRow(label: "Leading Dot", control: makeSwitch(isOn: false) { [weak self] isOn in
            self?.tag.showsLeadingDot = isOn
        })

        addRow(label: "Dismissable", control: makeSwitch(isOn: false) { [weak self] isOn in
            self?.tag.dismissAction = isOn ? HABAccessibleAction(label: "Dismiss") {} : nil
        })

        addSectionHeader("Content")

        addRow(label: "Label", control: makeSegmented(items: ["Status", "New", "Beta", "Sale"], selectedIndex: 0) { [weak self] index in
            self?.tag.label = ["Status", "New", "Beta", "Sale"][index]
        })
    }
}
