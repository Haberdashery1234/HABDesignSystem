//
//  SASelectionViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation
import HABUIKit

class SASelectionViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Selection"
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
        // MARK: HABToggle

        addHeader("HABToggle — Label Positions")
        let trailingToggle = HABToggle(label: "Trailing label (default)", isOn: true) { isOn in
            print("Toggle: \(isOn)")
        }
        stackView.addArrangedSubview(trailingToggle)

        let leadingToggle = HABToggle(label: "Leading label", labelPosition: .leading)
        stackView.addArrangedSubview(leadingToggle)

        addHeader("HABToggle — States")
        let onToggle = HABToggle(label: "On", isOn: true)
        stackView.addArrangedSubview(onToggle)

        let offToggle = HABToggle(label: "Off", isOn: false)
        stackView.addArrangedSubview(offToggle)

        let disabledToggle = HABToggle(label: "Disabled")
        disabledToggle.isEnabled = false
        stackView.addArrangedSubview(disabledToggle)

        addHeader("HABToggle — No Label")
        let bareToggle = HABToggle(isOn: true)
        stackView.addArrangedSubview(bareToggle)

        // MARK: HABSegmentedControl

        addHeader("HABSegmentedControl — 2 Segments")
        let twoSeg = HABSegmentedControl(items: ["On", "Off"]) { index in
            print("Segment: \(index)")
        }
        stackView.addArrangedSubview(twoSeg)

        addHeader("HABSegmentedControl — 3 Segments")
        let threeSeg = HABSegmentedControl(items: ["Day", "Week", "Month"])
        stackView.addArrangedSubview(threeSeg)

        addHeader("HABSegmentedControl — 4 Segments")
        let fourSeg = HABSegmentedControl(items: ["XS", "SM", "MD", "LG"])
        fourSeg.selectedIndex = 2
        stackView.addArrangedSubview(fourSeg)
    }

    private func addHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .habFootnote
        label.textColor = .secondaryLabel
        stackView.addArrangedSubview(label)
    }
}
