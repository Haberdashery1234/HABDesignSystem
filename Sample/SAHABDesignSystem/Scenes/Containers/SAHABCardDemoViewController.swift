//
//  SAHABCardDemoViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABCardDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let card = HABCard(style: .elevated)

    // MARK: - Content Views

    private let simpleContentView = UIView()
    private let richContentView = UIStackView()

    // MARK: - setupComponent

    override func setupComponent() {
        self.title = "HABCard"
        setPreviewHeight(240)

        card.translatesAutoresizingMaskIntoConstraints = false
        previewPanel.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: previewPanel.topAnchor, constant: HABSpacing.md),
            card.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor, constant: HABSpacing.md),
            card.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor, constant: -HABSpacing.md),
            card.bottomAnchor.constraint(equalTo: previewPanel.bottomAnchor, constant: -HABSpacing.md)
        ])

        setupSimpleContent()
        setupRichContent()

        richContentView.isHidden = true
    }

    // MARK: - Simple Content

    private func setupSimpleContent() {
        simpleContentView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(simpleContentView)

        NSLayoutConstraint.activate([
            simpleContentView.topAnchor.constraint(equalTo: card.topAnchor),
            simpleContentView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            simpleContentView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            simpleContentView.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        let bodyLabel = HABLabel(textStyle: .body)
        bodyLabel.text = "A surface container that groups related content. Use cards to create visual hierarchy."
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        simpleContentView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: simpleContentView.topAnchor, constant: HABSpacing.md),
            bodyLabel.leadingAnchor.constraint(equalTo: simpleContentView.leadingAnchor, constant: HABSpacing.md),
            bodyLabel.trailingAnchor.constraint(equalTo: simpleContentView.trailingAnchor, constant: -HABSpacing.md),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: simpleContentView.bottomAnchor, constant: -HABSpacing.md)
        ])
    }

    // MARK: - Rich Content

    private func setupRichContent() {
        richContentView.axis = .vertical
        richContentView.spacing = HABSpacing.sm
        richContentView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(richContentView)

        NSLayoutConstraint.activate([
            richContentView.topAnchor.constraint(equalTo: card.topAnchor, constant: HABSpacing.md),
            richContentView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: HABSpacing.md),
            richContentView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -HABSpacing.md),
            richContentView.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -HABSpacing.md)
        ])

        let headlineLabel = HABLabel(textStyle: .headline)
        headlineLabel.text = "Card Title"

        let divider = HABDivider()

        let bodyLabel = HABLabel(textStyle: .body)
        bodyLabel.text = "Supporting body text that gives the card more depth."

        richContentView.addArrangedSubview(headlineLabel)
        richContentView.addArrangedSubview(divider)
        richContentView.addArrangedSubview(bodyLabel)
    }

    // MARK: - setupSettings

    override func setupSettings() {
        addSectionHeader("Appearance")
        addRow(label: "Style", control: makeSegmented(items: ["Elevated", "Outlined", "Flat"]) { [weak self] index in
            guard let self else { return }
            switch index {
                case 0:
                    self.card.style = .elevated
                case 1:
                    self.card.style = .outlined
                default:
                    self.card.style = .flat
            }
        })

        addSectionHeader("Content")
        addRow(label: "Content", control: makeSegmented(items: ["Simple", "Rich"]) { [weak self] index in
            guard let self else { return }
            let isRich = index == 1
            self.simpleContentView.isHidden = isRich
            self.richContentView.isHidden = !isRich
        })
    }
}
