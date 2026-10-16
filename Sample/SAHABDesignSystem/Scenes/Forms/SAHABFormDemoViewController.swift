//
//  SAHABFormDemoViewController.swift
//  SAHABDesignSystem
//
//  A medication schedule form built from HABFormSection and HABFormRow, using
//  HABMenuButton, HABStepper, HABChipGroup, HABTextField.onTextChanged,
//  HABProgressBar and HABCalloutCard.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABFormDemoViewController: HABBaseViewController {
    // MARK: - Views

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private lazy var nameField = HABTextField(
        style: .filled,
        topLabel: "Name",
        onTextChanged: { [weak self] text in self?.nameDidChange(text) }
    )
    private lazy var detailsSection = HABFormSection(
        header: "Medication",
        footer: footerText(for: ""),
        rows: [HABFormRow(content: nameField)]
    )

    private let weekdays: HABChipGroup = {
        let calendar = Calendar.current
        let group = HABChipGroup(
            items: calendar.veryShortWeekdaySymbols,
            selectedIndices: [1, 3, 5],
            layout: .fillEqually
        )
        group.itemAccessibilityLabels = calendar.weekdaySymbols
        group.accessibilityLabel = "Days"
        return group
    }()
    private lazy var weekdaysRow = HABFormRow(content: weekdays)

    private let interval = HABStepper(
        value: 2,
        minimumValue: 1,
        maximumValue: 30,
        labelFormatter: { $0 == 1 ? "Every day" : "Every \(Int($0)) days" }
    )
    private lazy var intervalRow = HABFormRow(content: interval)

    private let progress = HABProgressBar(progress: 0.75, tint: .success)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Form"
        setupLayout()
        buildForm()
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        stack.axis = .vertical
        stack.spacing = HABSpacing.md
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: HABSpacing.sm, leading: HABSpacing.md, bottom: HABSpacing.xl, trailing: HABSpacing.md
        )
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    // MARK: - Form

    private func buildForm() {
        stack.addArrangedSubview(todaySection())
        stack.addArrangedSubview(detailsSection)
        stack.addArrangedSubview(scheduleSection())
        stack.addArrangedSubview(optionsSection())
    }

    private func todaySection() -> UIView {
        progress.accessibilityLabel = "Today's doses"
        progress.accessibilityValue = "3 of 4 taken"
        let progressRow = HABFormRow(content: progress)

        let morning = HABCalloutCard(
            tone: .success,
            title: "8:00 AM · Morning",
            message: "Lisinopril, Metformin — taken",
            icon: UIImage(systemName: "sun.max")
        )
        let evening = HABCalloutCard(
            tone: .warning,
            title: "9:00 PM · Evening",
            message: "Atorvastatin — due soon",
            icon: UIImage(systemName: "moon"),
            action: HABAccessibleAction(label: "Show evening doses") { [weak self] in
                guard let self else { return }
                HABToast.show(message: "Evening block tapped", in: self.view)
            }
        )
        let cards = UIStackView(arrangedSubviews: [morning, evening])
        cards.axis = .vertical
        cards.spacing = HABSpacing.sm

        let section = HABFormSection(header: "Today", headerDetail: "3 of 4 taken", rows: [progressRow])
        let container = UIStackView(arrangedSubviews: [section, cards])
        container.axis = .vertical
        container.spacing = HABSpacing.sm
        return container
    }

    private func scheduleSection() -> UIView {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = .habPrimary

        let repeatButton = HABMenuButton(
            titles: ["Daily", "Every few days", "On certain days"],
            selectedIndex: 2
        ) { [weak self] index in
            self?.updateRepeatRows(selectedIndex: index)
        }

        let section = HABFormSection(
            header: "Schedule",
            footer: "Change Repeat to see the rows below it, and their dividers, update.",
            rows: [
                HABFormRow(label: "Starts", control: datePicker),
                HABFormRow(label: "Repeat", control: repeatButton),
                intervalRow,
                weekdaysRow
            ]
        )
        updateRepeatRows(selectedIndex: 2)
        return section
    }

    private func optionsSection() -> UIView {
        let delayed = HABMenuButton(
            titles: ["Remind again", "Skip the dose", "Do nothing"],
            selectedIndex: 0
        )
        let alert = HABMenuButton(titles: ["At time of dose", "5 minutes before", "15 minutes before"], selectedIndex: 0)
        let critical = HABToggle(label: "Critical alerts", labelPosition: .leading)

        return HABFormSection(
            header: "Reminders",
            rows: [
                HABFormRow(label: "Alert", control: alert),
                HABFormRow(label: "If a dose is delayed", control: delayed),
                HABFormRow(content: critical)
            ]
        )
    }

    // MARK: - Behavior

    private func updateRepeatRows(selectedIndex: Int) {
        // Hiding rows is all it takes; the section's dividers follow the visible rows.
        intervalRow.isHidden = selectedIndex != 1
        weekdaysRow.isHidden = selectedIndex != 2
    }

    private func nameDidChange(_ text: String) {
        detailsSection.footer = footerText(for: text)
        nameField.errorText = text.count > 40 ? "Keep the name under 40 characters." : nil
    }

    private func footerText(for text: String) -> String {
        text.isEmpty ? "Type a name; this footer updates as you type." : "\(text.count) characters"
    }
}
