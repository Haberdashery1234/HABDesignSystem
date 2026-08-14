//
//  FeedbackViewController.swift
//  HABUIKitSample
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation
import HABUIKit

class FeedbackViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feedback"
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
        // MARK: HABToast

        addHeader("HABToast — Tap to Show")
        let toastRow = UIStackView()
        toastRow.axis = .horizontal
        toastRow.spacing = HABSpacing.sm
        toastRow.distribution = .fillEqually

        let styles: [(String, HABToast.Style)] = [
            ("Info", .info), ("Success", .success), ("Warning", .warning), ("Error", .error)
        ]
        for (title, _) in styles {
            let button = HABButton(style: .secondary, size: .small, title: title)
            button.addTarget(self, action: #selector(showToast(_:)), for: .touchUpInside)
            button.accessibilityIdentifier = title
            toastRow.addArrangedSubview(button)
        }
        stackView.addArrangedSubview(toastRow)

        // MARK: HABBanner

        addHeader("HABBanner — Info")
        stackView.addArrangedSubview(HABBanner(
            title: "New update available",
            message: "Version 2.1 includes performance improvements and bug fixes.",
            style: .info,
            action: HABAccessibleAction(label: "Update now") { print("Update tapped") }
        ))

        addHeader("HABBanner — Success")
        let successBanner = HABBanner(
            title: "Profile saved",
            message: "Your changes have been saved successfully.",
            style: .success
        )
        successBanner.dismissAction = HABAccessibleAction(label: "Dismiss success banner") {
            successBanner.removeFromSuperview()
        }
        stackView.addArrangedSubview(successBanner)

        addHeader("HABBanner — Warning")
        stackView.addArrangedSubview(HABBanner(
            title: "Storage almost full",
            message: "You're using 90% of your storage. Free up space to avoid interruptions.",
            style: .warning,
            action: HABAccessibleAction(label: "Manage storage") { print("Manage storage") }
        ))

        addHeader("HABBanner — Error")
        let errorBanner = HABBanner(
            title: "Connection failed",
            message: "Check your internet connection and try again.",
            style: .error,
            action: HABAccessibleAction(label: "Retry") { print("Retry") }
        )
        errorBanner.dismissAction = HABAccessibleAction(label: "Dismiss error") {
            errorBanner.removeFromSuperview()
        }
        stackView.addArrangedSubview(errorBanner)

        // MARK: HABLoadingView

        addHeader("HABLoadingView — Spinner")
        let spinner = HABLoadingView(style: .spinner, message: "Loading your content…")
        stackView.addArrangedSubview(spinner)

        addHeader("HABLoadingView — Progress Bar (60%)")
        let progressView = HABLoadingView(style: .linear, message: "Uploading photo…")
        progressView.progress = 0.6
        stackView.addArrangedSubview(progressView)

        addHeader("HABLoadingView — Indeterminate Progress")
        let indeterminateView = HABLoadingView(style: .linear)
        stackView.addArrangedSubview(indeterminateView)
        
        addHeader("HABLoadingView — Custom Spinner")
        let customSpinner = HABLoadingView(style: .customSpinner, message: "Processing…")
        customSpinner.customSpinnerColor = .systemPurple
        customSpinner.customSpinnerLineWidth = 4
        customSpinner.spinnerSize = CGSize(width: 50, height: 50)
        stackView.addArrangedSubview(customSpinner)
        
        addHeader("HABLoadingView — Custom Linear Progress (40%)")
        let customProgress = HABLoadingView(style: .customLinear, message: "Syncing data…")
        customProgress.progress = 0.4
        stackView.addArrangedSubview(customProgress)
        
        addHeader("HABLoadingView — Custom Animation (GIF)")
        // Load custom animated image from assets
        let animatedImage = UIImage(named: "SampleAnimatedLoading")
        let customAnimatedView = HABLoadingView(
            style: .customAnimation(animatedImage),
            message: "Loading with style…"
        )
        customAnimatedView.spinnerSize = CGSize(width: 80, height: 80)
        stackView.addArrangedSubview(customAnimatedView)

        // MARK: HABEmptyState

        addHeader("HABEmptyState — With Action")
        let emptyWithAction = HABEmptyState(
            title: "No messages yet",
            message: "When you receive messages, they'll appear here.",
            icon: UIImage(systemName: "envelope"),
            action: HABAccessibleAction(label: "Send your first message") {
                print("New message tapped")
            }
        )
        stackView.addArrangedSubview(emptyWithAction)

        addHeader("HABEmptyState — Icon Only")
        stackView.addArrangedSubview(HABEmptyState(
            title: "Nothing here",
            message: "Check back later.",
            icon: UIImage(systemName: "tray")
        ))

        addHeader("HABEmptyState — No Icon")
        stackView.addArrangedSubview(HABEmptyState(
            title: "All caught up",
            message: "You have no pending notifications."
        ))
    }

    @objc private func showToast(_ sender: HABButton) {
        guard let id = sender.accessibilityIdentifier else { return }
        let styleMap: [String: HABToast.Style] = [
            "Info": .info, "Success": .success, "Warning": .warning, "Error": .error
        ]
        guard let style = styleMap[id] else { return }
        let messages: [String: String] = [
            "Info": "Here's something you should know.",
            "Success": "Action completed successfully.",
            "Warning": "Proceed with caution.",
            "Error": "Something went wrong. Please try again."
        ]
        HABToast.show(message: messages[id] ?? id, style: style, in: view)
    }

    private func addHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .habFootnote
        label.textColor = .secondaryLabel
        stackView.addArrangedSubview(label)
    }
}
