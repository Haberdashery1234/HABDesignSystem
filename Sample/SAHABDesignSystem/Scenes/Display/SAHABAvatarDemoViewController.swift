//
//  SAHABAvatarDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABAvatarDemoViewController: SAComponentDemoViewController {
    private var avatar = HABAvatar(size: .large, name: "Christian Grise")

    override func setupComponent() {
        super.setupComponent()
        title = "HABAvatar"

        avatar.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(avatar)

        NSLayoutConstraint.activate([
            avatar.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            avatar.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor)
        ])
    }

    override func setupSettings() {
        super.setupSettings()

        addSectionHeader("Appearance")

        addRow(label: "Size", control: makeSegmented(items: ["SM", "MD", "LG"], selectedIndex: 2) { [weak self] index in
            self?.avatar.size = [HABAvatar.Size.small, .medium, .large][index]
        })

        addRow(label: "Shape", control: makeSegmented(items: ["Circle", "Rounded"], selectedIndex: 0) { [weak self] index in
            self?.avatar.shape = [HABAvatar.Shape.circle, .rounded][index]
        })

        addSectionHeader("Content")

        addRow(label: "Show Image", control: makeSwitch(isOn: false) { [weak self] isOn in
            self?.avatar.image = isOn ? UIImage(systemName: "person.fill") : nil
        })

        addRow(label: "Name", control: makeSegmented(items: ["Full", "Short", "None"], selectedIndex: 0) { [weak self] index in
            self?.avatar.name = ["Christian Grise", "TK", nil][index]
        })
    }
}
