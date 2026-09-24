//
//  SADisplayViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/4/26.
//

import UIKit
import HABFoundation
import HABUIKit

class SADisplayViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Display"
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
        // MARK: HABLabel

        addHeader("HABLabel — Plain Text")
        stackView.addArrangedSubview(makeLabel("Display", style: .display))
        stackView.addArrangedSubview(makeLabel("Large Title", style: .largeTitle))
        stackView.addArrangedSubview(makeLabel("Title 1", style: .title1))
        stackView.addArrangedSubview(makeLabel("Title 2", style: .title2))
        stackView.addArrangedSubview(makeLabel("Headline", style: .headline))
        stackView.addArrangedSubview(makeLabel("Body — the default reading size.", style: .body))
        stackView.addArrangedSubview(makeLabel("Subheadline", style: .subheadline))
        stackView.addArrangedSubview(makeLabel("Footnote", style: .footnote))
        stackView.addArrangedSubview(makeLabel("Caption 1", style: .caption1))

        addHeader("HABLabel — Styled Text (line height + tracking)")
        let styledLabel = HABLabel(textStyle: .body)
        styledLabel.styledText = """
            This label uses styledText, so line height and letter
            spacing tokens from the theme are applied. It rebuilds
            automatically when the theme or Dynamic Type setting changes.
        """
        stackView.addArrangedSubview(styledLabel)

        // MARK: HABTag

        addHeader("HABTag — Filled Style")
        let tagRow1 = horizontalWrapRow()
        tagRow1.addArrangedSubview(HABTag(label: "Primary", color: .primary))
        tagRow1.addArrangedSubview(HABTag(label: "Success", color: .success))
        tagRow1.addArrangedSubview(HABTag(label: "Warning", color: .warning))
        tagRow1.addArrangedSubview(HABTag(label: "Destructive", color: .destructive))
        tagRow1.addArrangedSubview(HABTag(label: "Neutral", color: .neutral))
        stackView.addArrangedSubview(tagRow1)

        addHeader("HABTag — Outlined Style")
        let tagRow2 = horizontalWrapRow()
        tagRow2.addArrangedSubview(HABTag(label: "Primary", style: .outlined, color: .primary))
        tagRow2.addArrangedSubview(HABTag(label: "Success", style: .outlined, color: .success))
        tagRow2.addArrangedSubview(HABTag(label: "Warning", style: .outlined, color: .warning))
        tagRow2.addArrangedSubview(HABTag(label: "Neutral", style: .outlined, color: .neutral))
        stackView.addArrangedSubview(tagRow2)

        addHeader("HABTag — With Dot & Dismiss")
        let tagRow3 = horizontalWrapRow()
        let dotTag = HABTag(label: "Live", color: .success)
        dotTag.showsLeadingDot = true
        tagRow3.addArrangedSubview(dotTag)
        let dismissTag = HABTag(label: "Dismissible", color: .primary)
        dismissTag.dismissAction = HABAccessibleAction(label: "Dismiss tag") {
            dismissTag.removeFromSuperview()
        }
        tagRow3.addArrangedSubview(dismissTag)
        stackView.addArrangedSubview(tagRow3)

        // MARK: HABBadge

        addHeader("HABBadge")
        let badgeRow = horizontalWrapRow()
        badgeRow.spacing = HABSpacing.xl

        for count in [1, 5, 12, 99, 100] {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false

            let icon = UIImageView(image: UIImage(systemName: "bell.fill"))
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.tintColor = .habForegroundSecondary
            icon.contentMode = .scaleAspectFit

            let badge = HABBadge()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.number = count

            container.addSubview(icon)
            container.addSubview(badge)

            NSLayoutConstraint.activate([
                icon.widthAnchor.constraint(equalToConstant: 28),
                icon.heightAnchor.constraint(equalToConstant: 28),
                icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                container.widthAnchor.constraint(equalToConstant: 44),
                container.heightAnchor.constraint(equalToConstant: 44),
                badge.topAnchor.constraint(equalTo: icon.topAnchor, constant: -6),
                badge.trailingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10)
            ])

            badgeRow.addArrangedSubview(container)
        }
        stackView.addArrangedSubview(badgeRow)

        // MARK: HABAvatar

        addHeader("HABAvatar — Sizes (initials fallback)")
        let avatarRow1 = horizontalWrapRow()
        avatarRow1.spacing = HABSpacing.md
        avatarRow1.alignment = .center
        avatarRow1.addArrangedSubview(HABAvatar(size: .small, name: "Christian Grise"))
        avatarRow1.addArrangedSubview(HABAvatar(size: .medium, name: "Christian Grise"))
        avatarRow1.addArrangedSubview(HABAvatar(size: .large, name: "Christian Grise"))
        stackView.addArrangedSubview(avatarRow1)

        addHeader("HABAvatar — With Image & Shapes")
        let avatarRow2 = horizontalWrapRow()
        avatarRow2.spacing = HABSpacing.md
        avatarRow2.alignment = .center
        let circleAvatar = HABAvatar(size: .large, name: "Circle")
        circleAvatar.shape = .circle
        avatarRow2.addArrangedSubview(circleAvatar)
        let roundedAvatar = HABAvatar(size: .large, name: "Rounded")
        roundedAvatar.shape = .rounded
        avatarRow2.addArrangedSubview(roundedAvatar)
        let fallbackAvatar = HABAvatar(size: .large, name: nil)
        avatarRow2.addArrangedSubview(fallbackAvatar)
        stackView.addArrangedSubview(avatarRow2)
    }

    // MARK: - Helpers

    private func makeLabel(_ text: String, style: HABTypographyKey) -> HABLabel {
        let label = HABLabel(textStyle: style)
        label.text = text
        return label
    }

    private func horizontalWrapRow() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = HABSpacing.sm
        stack.alignment = .center
        stack.flexibleContainer()
        return stack
    }

    private func addHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .habFootnote
        label.textColor = .secondaryLabel
        stackView.addArrangedSubview(label)
    }
}

private extension UIStackView {
    func flexibleContainer() {
        // Allow row to wrap naturally inside the parent stack
    }
}
