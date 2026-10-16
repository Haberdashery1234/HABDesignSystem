//
//  SAHABCalloutCardDemoViewController.swift
//  SAHABDesignSystem
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABCalloutCardDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let card = HABCalloutCard(
        tone: .success,
        title: "8:00 AM · Morning",
        message: "Lisinopril, Metformin — taken",
        icon: UIImage(systemName: "sun.max")
    )

    // MARK: - Setup

    override func setupComponent() {
        title = "HABCalloutCard"
        setPreviewHeight(200)
        previewPanel.addSubview(card)

        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.md),
            card.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.md)
        ])
    }

    override func setupSettings() {
        addSectionHeader("Appearance")

        let tones: [HABCalloutCard.Tone] = [.primary, .info, .success, .warning, .destructive, .neutral]
        let toneSeg = makeSegmented(items: ["Pri", "Info", "OK", "Warn", "Err", "Neu"], selectedIndex: 2) { [weak self] index in
            self?.card.tone = tones[index]
        }
        addRow(label: "Tone", control: toneSeg)

        addSectionHeader("Options")

        let iconSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.card.icon = isOn ? UIImage(systemName: "sun.max") : nil
        }
        addRow(label: "Icon", control: iconSwitch)

        let messageSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.card.message = isOn ? "Lisinopril, Metformin — taken" : nil
        }
        addRow(label: "Message", control: messageSwitch)

        let tappableSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            guard let self else { return }
            self.card.action = isOn
                ? HABAccessibleAction(label: "Show morning doses") { [weak self] in
                    guard let self else { return }
                    HABToast.show(message: "Card tapped", in: self.view)
                }
                : nil
        }
        addRow(label: "Tappable", control: tappableSwitch)
    }
}
