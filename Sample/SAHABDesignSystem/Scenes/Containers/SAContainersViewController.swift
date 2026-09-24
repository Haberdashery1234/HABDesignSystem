//
//  SAContainersViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

class SAContainersViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Containers"
        view.backgroundColor = .habBackground
        setupLayout()
        addSamples()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = HABSpacing.lg
        stackView.layoutMargins = UIEdgeInsets(
            top: HABSpacing.lg, left: HABSpacing.lg,
            bottom: HABSpacing.lg, right: HABSpacing.lg
        )
        stackView.isLayoutMarginsRelativeArrangement = true

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func addSamples() {
        // MARK: HABCard

        addHeader("HABCard — Elevated (default)")
        stackView.addArrangedSubview(
            sampleCard(
                style: .elevated,
                description: "Elevated card with a low shadow. Good for content that needs to stand above the background."
            )
        )

        addHeader("HABCard — Outlined")
        stackView.addArrangedSubview(
            sampleCard(
                style: .outlined,
                description: "Outlined card with a 1pt border. Works well on plain backgrounds where shadows feel heavy."
            )
        )

        addHeader("HABCard — Flat")
        stackView.addArrangedSubview(
            sampleCard(
                style: .flat,
                description: "Flat card with no border or shadow. Use inside an already-elevated container."
            )
        )

        addHeader("HABCard — Rich Content")
        stackView.addArrangedSubview(richCard())

        // MARK: HABDivider

        addHeader("HABDivider — Horizontal")
        stackView.addArrangedSubview(HABDivider())

        addHeader("HABDivider — Between Items")
        stackView.addArrangedSubview(dividedList())

        addHeader("HABDivider — Vertical")
        let verticalDividerContainer = UIView()
        verticalDividerContainer.translatesAutoresizingMaskIntoConstraints = false

        let leftLabel = UILabel()
        leftLabel.text = "Left"
        leftLabel.font = .habBody
        leftLabel.textColor = .habForeground
        leftLabel.translatesAutoresizingMaskIntoConstraints = false

        let divider = HABDivider(axis: .vertical)
        divider.translatesAutoresizingMaskIntoConstraints = false

        let rightLabel = UILabel()
        rightLabel.text = "Right"
        rightLabel.font = .habBody
        rightLabel.textColor = .habForeground
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        verticalDividerContainer.addSubview(leftLabel)
        verticalDividerContainer.addSubview(divider)
        verticalDividerContainer.addSubview(rightLabel)

        NSLayoutConstraint.activate([
            verticalDividerContainer.heightAnchor.constraint(equalToConstant: 44),
            leftLabel.leadingAnchor.constraint(equalTo: verticalDividerContainer.leadingAnchor),
            leftLabel.centerYAnchor.constraint(equalTo: verticalDividerContainer.centerYAnchor),
            divider.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: HABSpacing.md),
            divider.topAnchor.constraint(equalTo: verticalDividerContainer.topAnchor, constant: HABSpacing.sm),
            divider.bottomAnchor.constraint(equalTo: verticalDividerContainer.bottomAnchor, constant: -HABSpacing.sm),
            rightLabel.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: HABSpacing.md),
            rightLabel.centerYAnchor.constraint(equalTo: verticalDividerContainer.centerYAnchor)
        ])

        stackView.addArrangedSubview(verticalDividerContainer)
    }

    // MARK: - Card Factories

    private func sampleCard(style: HABCard.Style, description: String) -> HABCard {
        let card = HABCard(style: style)
        card.translatesAutoresizingMaskIntoConstraints = false

        let label = HABLabel(textStyle: .body)
        label.text = description
        label.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: HABSpacing.md),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: HABSpacing.md),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -HABSpacing.md),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -HABSpacing.md)
        ])

        return card
    }

    private func richCard() -> HABCard {
        let card = HABCard(style: .elevated)
        card.translatesAutoresizingMaskIntoConstraints = false

        let avatar = HABAvatar(size: .medium, name: "Christian Grise")
        avatar.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = HABLabel(textStyle: .headline)
        nameLabel.text = "Christian Grise"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let roleLabel = HABLabel(textStyle: .subheadline)
        roleLabel.text = "iOS Developer"
        roleLabel.themeTextColor = { .habForegroundSecondary }
        roleLabel.translatesAutoresizingMaskIntoConstraints = false

        let tag = HABTag(label: "Active", style: .filled, color: .success)
        tag.showsLeadingDot = true
        tag.translatesAutoresizingMaskIntoConstraints = false

        let divider = HABDivider()
        divider.translatesAutoresizingMaskIntoConstraints = false

        let bodyLabel = HABLabel(textStyle: .body)
        bodyLabel.text = "Building HABUIKit — a design system framework for keeping iOS apps visually consistent."
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(avatar)
        card.addSubview(nameLabel)
        card.addSubview(roleLabel)
        card.addSubview(tag)
        card.addSubview(divider)
        card.addSubview(bodyLabel)

        let padding = HABSpacing.md
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: card.topAnchor, constant: padding),
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),

            nameLabel.topAnchor.constraint(equalTo: avatar.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: HABSpacing.sm),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: tag.leadingAnchor, constant: -HABSpacing.sm),

            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            tag.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            tag.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),

            divider.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: padding),
            divider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),

            bodyLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: padding),
            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),
            bodyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),
            bodyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -padding)
        ])

        return card
    }

    private func dividedList() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let card = HABCard(style: .outlined)
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: container.topAnchor),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let items = ["Notifications", "Privacy", "Appearance", "Help & Support"]
        var lastAnchor = card.topAnchor

        for (index, item) in items.enumerated() {
            let row = UILabel()
            row.text = item
            row.font = .habBody
            row.textColor = .habForeground
            row.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(row)

            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: lastAnchor, constant: HABSpacing.md),
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: HABSpacing.md),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -HABSpacing.md)
            ])
            lastAnchor = row.bottomAnchor

            if index < items.count - 1 {
                let divider = HABDivider()
                divider.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(divider)
                NSLayoutConstraint.activate([
                    divider.topAnchor.constraint(equalTo: row.bottomAnchor, constant: HABSpacing.md),
                    divider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: HABSpacing.md),
                    divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -HABSpacing.md)
                ])
                lastAnchor = divider.bottomAnchor
            }
        }

        lastAnchor.constraint(equalTo: card.bottomAnchor, constant: -HABSpacing.md).isActive = true
        return container
    }

    // MARK: - Helpers

    private func addHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .habFootnote
        label.textColor = .secondaryLabel
        stackView.addArrangedSubview(label)
    }
}
