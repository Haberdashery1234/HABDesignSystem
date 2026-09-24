//
//  SAHABDividerDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABDividerDemoViewController: SAComponentDemoViewController {
    // MARK: - Section Container Views

    private let horizontalSection = UIView()
    private let verticalSection = UIView()

    // MARK: - Dividers

    private let horizontalDivider = HABDivider(axis: .horizontal)
    private let verticalDivider = HABDivider(axis: .vertical)

    // MARK: - setupComponent

    override func setupComponent() {
        self.title = "HABDivider"
        setPreviewHeight(200)

        setupHorizontalSection()
        setupVerticalSection()

        horizontalSection.translatesAutoresizingMaskIntoConstraints = false
        verticalSection.translatesAutoresizingMaskIntoConstraints = false

        previewPanel.addSubview(horizontalSection)
        previewPanel.addSubview(verticalSection)

        NSLayoutConstraint.activate([
            horizontalSection.topAnchor.constraint(equalTo: previewPanel.topAnchor, constant: HABSpacing.md),
            horizontalSection.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor),
            horizontalSection.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor),

            verticalSection.topAnchor.constraint(equalTo: horizontalSection.bottomAnchor, constant: HABSpacing.md),
            verticalSection.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor),
            verticalSection.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor),
            verticalSection.bottomAnchor.constraint(lessThanOrEqualTo: previewPanel.bottomAnchor, constant: -HABSpacing.md)
        ])
    }

    // MARK: - Horizontal Section

    private func setupHorizontalSection() {
        let headerLabel = UILabel()
        headerLabel.text = "Horizontal"
        headerLabel.font = .habCaption1
        headerLabel.textColor = .habForegroundTertiary
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        horizontalDivider.translatesAutoresizingMaskIntoConstraints = false

        horizontalSection.addSubview(headerLabel)
        horizontalSection.addSubview(horizontalDivider)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: horizontalSection.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: horizontalSection.leadingAnchor, constant: HABSpacing.md),
            headerLabel.trailingAnchor.constraint(equalTo: horizontalSection.trailingAnchor, constant: -HABSpacing.md),

            horizontalDivider.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: HABSpacing.xs),
            horizontalDivider.leadingAnchor.constraint(equalTo: horizontalSection.leadingAnchor, constant: HABSpacing.md),
            horizontalDivider.trailingAnchor.constraint(equalTo: horizontalSection.trailingAnchor, constant: -HABSpacing.md),
            horizontalDivider.bottomAnchor.constraint(equalTo: horizontalSection.bottomAnchor)
        ])
    }

    // MARK: - Vertical Section

    private func setupVerticalSection() {
        let headerLabel = UILabel()
        headerLabel.text = "Vertical"
        headerLabel.font = .habCaption1
        headerLabel.textColor = .habForegroundTertiary
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        let leftLabel = UILabel()
        leftLabel.text = "Left"
        leftLabel.font = .habBody
        leftLabel.textColor = .habForeground
        leftLabel.translatesAutoresizingMaskIntoConstraints = false

        let rightLabel = UILabel()
        rightLabel.text = "Right"
        rightLabel.font = .habBody
        rightLabel.textColor = .habForeground
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        verticalDivider.translatesAutoresizingMaskIntoConstraints = false

        let wordsContainer = UIView()
        wordsContainer.translatesAutoresizingMaskIntoConstraints = false
        wordsContainer.addSubview(leftLabel)
        wordsContainer.addSubview(verticalDivider)
        wordsContainer.addSubview(rightLabel)

        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: wordsContainer.leadingAnchor, constant: HABSpacing.md),
            leftLabel.centerYAnchor.constraint(equalTo: wordsContainer.centerYAnchor),

            verticalDivider.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: HABSpacing.md),
            verticalDivider.topAnchor.constraint(equalTo: wordsContainer.topAnchor, constant: HABSpacing.xs),
            verticalDivider.bottomAnchor.constraint(equalTo: wordsContainer.bottomAnchor, constant: -HABSpacing.xs),

            rightLabel.leadingAnchor.constraint(equalTo: verticalDivider.trailingAnchor, constant: HABSpacing.md),
            rightLabel.centerYAnchor.constraint(equalTo: wordsContainer.centerYAnchor),
            rightLabel.trailingAnchor.constraint(lessThanOrEqualTo: wordsContainer.trailingAnchor, constant: -HABSpacing.md),

            wordsContainer.heightAnchor.constraint(equalToConstant: 36)
        ])

        verticalSection.addSubview(headerLabel)
        verticalSection.addSubview(wordsContainer)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: verticalSection.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: verticalSection.leadingAnchor, constant: HABSpacing.md),
            headerLabel.trailingAnchor.constraint(equalTo: verticalSection.trailingAnchor, constant: -HABSpacing.md),

            wordsContainer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: HABSpacing.xs),
            wordsContainer.leadingAnchor.constraint(equalTo: verticalSection.leadingAnchor),
            wordsContainer.trailingAnchor.constraint(equalTo: verticalSection.trailingAnchor),
            wordsContainer.bottomAnchor.constraint(equalTo: verticalSection.bottomAnchor)
        ])
    }

    // MARK: - setupSettings

    override func setupSettings() {
        addSectionHeader("Appearance")
        addRow(label: "Preview", control: makeSegmented(items: ["Both", "Horizontal", "Vertical"]) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.horizontalSection.isHidden = false
                    self.verticalSection.isHidden = false
                case 1:
                    self.horizontalSection.isHidden = false
                    self.verticalSection.isHidden = true
                default:
                    self.horizontalSection.isHidden = true
                    self.verticalSection.isHidden = false
            }
        })
    }
}
