//
//  SAInputsViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation
import HABUIKit

class SAInputsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inputs"
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
        // MARK: HABTextField

        addHeader("HABTextField — Outlined")
        let emailField = HABTextField(topLabel: "Email")
        emailField.placeholder = "you@example.com"
        emailField.keyboardType = .emailAddress
        stackView.addArrangedSubview(emailField)

        addHeader("HABTextField — Filled")
        let usernameField = HABTextField(style: .filled, topLabel: "Username")
        usernameField.placeholder = "Enter username"
        stackView.addArrangedSubview(usernameField)

        addHeader("HABTextField — Helper Text")
        let passwordField = HABTextField(topLabel: "Password", helperText: "Use a mix of letters, numbers, and symbols")
        passwordField.placeholder = "Min 8 characters"
        passwordField.isSecureTextEntry = true
        stackView.addArrangedSubview(passwordField)

        addHeader("HABTextField — Error State")
        let errorField = HABTextField(topLabel: "Email", errorText: "Please enter a valid email address")
        errorField.placeholder = "you@example.com"
        stackView.addArrangedSubview(errorField)

        addHeader("HABTextField — Leading Icon")
        let searchField = HABTextField(
            topLabel: "Search",
            leadingIcon: UIImage(systemName: "magnifyingglass")
        )
        searchField.placeholder = "Search…"
        stackView.addArrangedSubview(searchField)

        addHeader("HABTextField — Trailing Action")
        let clearField = HABTextField(
            topLabel: "With Clear Button",
            leadingIcon: UIImage(systemName: "magnifyingglass"),
            trailingIcon: UIImage(systemName: "xmark.circle.fill")
        )
        clearField.placeholder = "Type to search…"
        clearField.trailingAction = HABAccessibleAction(label: "Clear search field") { [weak clearField] in
            clearField?.text = ""
        }
        stackView.addArrangedSubview(clearField)

        addHeader("HABTextField — Disabled")
        let disabledField = HABTextField(topLabel: "Account ID", isDisabled: true)
        disabledField.text = "ACC-8271-XZ"
        stackView.addArrangedSubview(disabledField)

        // MARK: HABTextView

        addHeader("HABTextView — Outlined")
        let outlinedTextView = HABTextView()
        outlinedTextView.topLabel = "Notes"
        outlinedTextView.placeholder = "Add a note…"
        outlinedTextView.helperText = "This will be visible to your team."
        stackView.addArrangedSubview(outlinedTextView)

        addHeader("HABTextView — Filled")
        let filledTextView = HABTextView()
        filledTextView.style = .filled
        filledTextView.topLabel = "Bio"
        filledTextView.placeholder = "Tell us about yourself…"
        stackView.addArrangedSubview(filledTextView)

        addHeader("HABTextView — Error State")
        let errorTextView = HABTextView()
        errorTextView.topLabel = "Description"
        errorTextView.placeholder = "Describe the issue…"
        errorTextView.errorText = "Description is required."
        stackView.addArrangedSubview(errorTextView)

        addHeader("HABTextView — Disabled")
        let disabledTextView = HABTextView()
        disabledTextView.topLabel = "Read-only Notes"
        disabledTextView.text = "This content cannot be edited."
        disabledTextView.isDisabled = true
        stackView.addArrangedSubview(disabledTextView)
    }

    private func addHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .habFootnote
        label.textColor = .secondaryLabel
        stackView.addArrangedSubview(label)
    }
}
