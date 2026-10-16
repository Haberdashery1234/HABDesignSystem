//
//  SAHABImageViewDemoViewController.swift
//  SAHABDesignSystem
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABImageViewDemoViewController: SAComponentDemoViewController {
    // MARK: - Component

    private let sampleImage = UIImage(systemName: "photo.artframe")
    private lazy var imageView = HABImageView(
        image: sampleImage,
        placeholder: UIImage(systemName: "photo"),
        imageContentMode: .scaleAspectFit
    )

    // MARK: - Setup

    override func setupComponent() {
        title = "HABImageView"
        setPreviewHeight(240)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.cornerRadius = HABRadius.md
        imageView.accessibilityLabel = "Sample artwork"
        previewPanel.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: previewPanel.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: previewPanel.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 160),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    override func setupSettings() {
        addSectionHeader("Appearance")

        let modes: [HABImageView.ImageContentMode] = [.scaleAspectFill, .scaleAspectFit, .center]
        let modeSeg = makeSegmented(items: ["Fill", "Fit", "Center"], selectedIndex: 1) { [weak self] index in
            self?.imageView.imageContentMode = modes[index]
        }
        addRow(label: "Content Mode", control: modeSeg)

        let radiusStepper = makeStepper(
            value: Double(HABRadius.md),
            min: 0,
            max: 60,
            step: 4,
            format: { "\(Int($0)) pt" },
            onChange: { [weak self] value in self?.imageView.cornerRadius = CGFloat(value) }
        )
        addRow(label: "Corner Radius", control: radiusStepper)

        addSectionHeader("Content")

        let imageSwitch = makeSwitch(isOn: true) { [weak self] isOn in
            guard let self else { return }
            // With no image, the placeholder shows instead.
            self.imageView.image = isOn ? self.sampleImage : nil
        }
        addRow(label: "Image (off shows placeholder)", control: imageSwitch)
    }
}
