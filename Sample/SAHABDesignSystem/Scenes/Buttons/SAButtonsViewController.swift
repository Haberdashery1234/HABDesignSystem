//
//  SAButtonsViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation
import HABUIKit

class SAButtonsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buttons"
        view.backgroundColor = .systemBackground
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
        addHeader("Styles")
        stackView.addArrangedSubview(HABButton(style: .primary, title: "Primary"))
        stackView.addArrangedSubview(HABButton(style: .secondary, title: "Secondary"))
        stackView.addArrangedSubview(HABButton(style: .ghost, title: "Ghost"))
        stackView.addArrangedSubview(HABButton(style: .destructive, title: "Destructive"))

        addHeader("Sizes")
        stackView.addArrangedSubview(HABButton(style: .primary, size: .small, title: "Small"))
        stackView.addArrangedSubview(HABButton(style: .primary, size: .medium, title: "Medium"))
        stackView.addArrangedSubview(HABButton(style: .primary, size: .large, title: "Large"))

        addHeader("With Icon")
        let icon = UIImage(systemName: "star.fill")
        stackView.addArrangedSubview(HABButton(style: .primary, title: "Leading Icon", icon: icon, iconPosition: .leading))
        stackView.addArrangedSubview(HABButton(style: .primary, title: "Trailing Icon", icon: icon, iconPosition: .trailing))
        stackView.addArrangedSubview(HABButton(style: .secondary, icon: icon))

        addHeader("States")
        let disabledButton = HABButton(style: .primary, title: "Disabled")
        disabledButton.isEnabled = false
        stackView.addArrangedSubview(disabledButton)

        let loadingButton = HABButton(style: .primary, title: "Loading")
        loadingButton.isLoading = true
        stackView.addArrangedSubview(loadingButton)
    }

    private func addHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .habFootnote
        label.textColor = .secondaryLabel
        stackView.addArrangedSubview(label)
    }
}
