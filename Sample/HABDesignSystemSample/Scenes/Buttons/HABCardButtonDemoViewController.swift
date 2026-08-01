//
//  HABCardButtonDemoViewController.swift
//  HABUIKitSample
//

import UIKit
import HABFoundation
import HABUIKit

final class HABCardButtonDemoViewController: ComponentDemoViewController {

    // MARK: - Component

    private let cardButton = HABCardButton(
        style: .elevated,
        icon: UIImage(systemName: "doc.text.fill"),
        title: "Reports",
        subtitle: "View recent activity"
    )

    // MARK: - Setup

    override func setupComponent() {
        title = "HABCardButton"
        setPreviewHeight(240)

        cardButton.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(cardButton)

        NSLayoutConstraint.activate([
            cardButton.widthAnchor.constraint(equalToConstant: 160),
            cardButton.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            cardButton.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor),
        ])

        cardButton.addTarget(self, action: #selector(cardButtonTapped), for: .touchUpInside)
    }

    override func setupSettings() {
        // APPEARANCE
        addSectionHeader("Appearance")

        let styleSeg = makeSegmented(items: ["Elev", "Outl", "Flat"], selectedIndex: 0) { [weak self] index in
            switch index {
            case 0: self?.cardButton.style = .elevated
            case 1: self?.cardButton.style = .outlined
            case 2: self?.cardButton.style = .flat
            default: break
            }
        }
        addRow(label: "Style", control: styleSeg)
        
        let alignmentSeg = makeSegmented(items: ["Leading", "Center", "Trailing"], selectedIndex: 0) { [weak self] index in
            switch index {
            case 0: self?.cardButton.alignment = .leading
            case 1: self?.cardButton.alignment = .center
            case 2: self?.cardButton.alignment = .trailing
            default: break
            }
        }
        addRow(label: "Alignment", control: alignmentSeg)

        let squareSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.cardButton.isSquare = isOn
        }
        addRow(label: "isSquare", control: squareSwitch)

        // CONTENT
        addSectionHeader("Content")

        let iconSeg = makeSegmented(items: ["None", "Doc", "Star", "Map"], selectedIndex: 1) { [weak self] index in
            switch index {
            case 0: self?.cardButton.icon = nil
            case 1: self?.cardButton.icon = UIImage(systemName: "doc.text.fill")
            case 2: self?.cardButton.icon = UIImage(systemName: "star.fill")
            case 3: self?.cardButton.icon = UIImage(systemName: "map.fill")
            default: break
            }
        }
        addRow(label: "Icon", control: iconSeg)

        let subtitleSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.cardButton.subtitle = isOn ? "View recent activity" : nil
        }
        addRow(label: "Subtitle", control: subtitleSwitch)

        // STATE
        addSectionHeader("State")

        let enabledSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            self?.cardButton.isEnabled = isOn
        }
        addRow(label: "isEnabled", control: enabledSwitch)
    }

    // MARK: - Actions

    @objc private func cardButtonTapped() {
        HABToast.show(message: "Card button tapped", in: self.view)
    }
}
