//
//  SAHABBannerDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABBannerDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let banner = HABBanner(
        title: "Update available",
        message: "Version 2.1 is ready to install.",
        style: .info,
        action: nil,
        dismissAction: nil
    )

    // MARK: - setupComponent

    override func setupComponent() {
        self.title = "HABBanner"
        setPreviewHeight(240)

        banner.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: previewPanel.topAnchor, constant: HABSpacing.md),
            banner.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.md),
            banner.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.md),
            banner.bottomAnchor.constraint(lessThanOrEqualTo: previewPanel.bottomAnchor, constant: -HABSpacing.md)
        ])
    }

    // MARK: - setupSettings

    override func setupSettings() {
        addSectionHeader("Appearance")
        addRow(label: "Style", control: makeSegmented(items: ["Info", "Succ", "Warn", "Error"]) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.banner.style = .info
                case 1:
                    self.banner.style = .success
                case 2:
                    self.banner.style = .warning
                default:
                    self.banner.style = .error
            }
        })

        addSectionHeader("Options")
        addRow(label: "Message", control: makeSwitch(isOn: true) { [weak self] isOn in
            guard let self else { return }
            self.banner.message = isOn ? "Version 2.1 is ready to install." : nil
        })

        addRow(label: "Action", control: makeSwitch(isOn: false) { [weak self] isOn in
            guard let self else { return }
            self.banner.action = isOn ? HABAccessibleAction(label: "Update") {} : nil
        })

        addRow(label: "Dismiss", control: makeSwitch(isOn: false) { [weak self] isOn in
            guard let self else { return }
            self.banner.dismissAction = isOn ? HABAccessibleAction(label: "Dismiss") {} : nil
        })
    }
}
