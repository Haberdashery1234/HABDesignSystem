//
//  SAPlaceholderViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 7/3/26.
//

import UIKit
import HABFoundation
import HABUIKit

/// A generic "coming soon" screen used for components not yet implemented.
class SAPlaceholderViewController: UIViewController {
    private let componentTitle: String

    init(title: String) {
        self.componentTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = componentTitle
        view.backgroundColor = .systemBackground

        let icon = UIImageView(image: UIImage(systemName: "hammer.fill"))
        icon.tintColor = .habForegroundTertiary
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "\(componentTitle) — coming soon"
        label.font = .habBody
        label.textColor = .habForegroundSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(icon)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -HABSpacing.lg),
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalToConstant: 44),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: HABSpacing.md),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: HABSpacing.lg),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -HABSpacing.lg)
        ])
    }
}
