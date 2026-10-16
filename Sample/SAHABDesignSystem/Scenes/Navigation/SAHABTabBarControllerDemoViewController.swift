//
//  SAHABTabBarControllerDemoViewController.swift
//  SAHABDesignSystem
//
//  An HABTabBarController shown as a child in the preview, with controls for
//  badges and selection, and a readout of onTabSelected so you can check that
//  taps reach it.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABTabBarControllerDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let tabTitles = ["Today", "Medications", "Profile"]
    private let tabSymbols = ["sun.max", "pills", "person.crop.circle"]

    private lazy var tabBarDemo = HABTabBarController(
        tabs: tabTitles.indices.map { index in
            HABTab(
                title: tabTitles[index],
                image: UIImage(systemName: tabSymbols[index]),
                selectedImage: UIImage(systemName: tabSymbols[index] + ".fill"),
                viewController: SATabContentViewController(text: tabTitles[index]),
                accessibilityIdentifier: "demoTab.\(index)"
            )
        }
    )

    private let lastTapLabel = HABLabel(textStyle: .footnote)

    // MARK: - Setup

    override func setupComponent() {
        title = "HABTabBarController"
        setPreviewHeight(300)

        addChild(tabBarDemo)
        tabBarDemo.view.translatesAutoresizingMaskIntoConstraints = false
        tabBarDemo.view.layer.cornerRadius = HABRadius.md
        tabBarDemo.view.clipsToBounds = true
        previewPanel.addSubview(tabBarDemo.view)
        tabBarDemo.didMove(toParent: self)

        NSLayoutConstraint.activate([
            tabBarDemo.view.topAnchor.constraint(equalTo: previewPanel.topAnchor),
            tabBarDemo.view.leadingAnchor.constraint(equalTo: previewPanel.leadingAnchor),
            tabBarDemo.view.trailingAnchor.constraint(equalTo: previewPanel.trailingAnchor),
            tabBarDemo.view.bottomAnchor.constraint(equalTo: previewPanel.bottomAnchor)
        ])

        tabBarDemo.onTabSelected = { [weak self] index in
            guard let self else { return }
            self.lastTapLabel.text = "onTabSelected: \(self.tabTitles[index])"
        }
    }

    override func setupSettings() {
        addSectionHeader("Selection")

        let selectedSeg = makeSegmented(items: tabTitles, selectedIndex: 0) { [weak self] index in
            // Setting selectedIndex in code doesn't call onTabSelected.
            self?.tabBarDemo.selectedIndex = index
        }
        addRow(label: "Selected", control: selectedSeg)

        lastTapLabel.text = "Tap a tab to see onTabSelected"
        lastTapLabel.numberOfLines = 0
        addRow(label: "Last tap", control: lastTapLabel)

        addSectionHeader("Badges")

        let badgeStepper = makeStepper(
            value: 3,
            min: 0,
            max: 120,
            step: 1,
            format: { $0 > Double(HABTabBarController.maximumBadgeCount) ? "\(Int($0)) (99+)" : "\(Int($0))" },
            onChange: { [weak self] value in self?.tabBarDemo.setBadgeCount(Int(value), forTabAt: 1) }
        )
        addRow(label: "Medications badge", control: badgeStepper)
        tabBarDemo.setBadgeCount(3, forTabAt: 1)

        let textBadgeSwitch = makeSwitch(isOn: false) { [weak self] isOn in
            self?.tabBarDemo.setBadgeValue(isOn ? "New" : nil, forTabAt: 2)
        }
        addRow(label: "Profile \"New\" badge", control: textBadgeSwitch)
    }
}

/// A simple screen for each demo tab.
private final class SATabContentViewController: HABBaseViewController {
    private let text: String
    private let label = HABLabel(textStyle: .title2)

    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
        title = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
