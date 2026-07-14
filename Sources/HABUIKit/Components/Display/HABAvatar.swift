//
//  HABAvatar.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABAvatar: UIView {
    // MARK: - Public Types

    public enum Size {
        case small   // 32pt
        case medium  // 40pt
        case large   // 56pt

        public var points: CGFloat {
            switch self {
                case .small:
                    return 32
                case .medium:
                    return 40
                case .large:
                    return 56
            }
        }
    }

    public enum Shape {
        case circle
        case rounded
    }

    // MARK: - Public Properties

    public var image: UIImage? {
        didSet { updateAppearance() }
    }

    public var name: String? {
        didSet { updateAppearance() }
    }

    public var size: Size {
        didSet { updateAppearance() }
    }

    public var shape: Shape = .circle {
        didSet { updateAppearance() }
    }

    // MARK: - Private Subviews

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    // MARK: - Stored Size Constraints

    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Init

    public init(size: Size = .medium, name: String? = nil, image: UIImage? = nil) {
        self.size = size
        self.name = name
        self.image = image
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        setupView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )

        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        addSubview(imageView)
        addSubview(initialsLabel)

        clipsToBounds = true

        // imageView fills self
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // initialsLabel centered in self
            initialsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            initialsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            initialsLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4)
        ])

        // Size constraints — stored so we can update them when `size` changes
        let diameter = size.points
        widthConstraint = widthAnchor.constraint(equalToConstant: diameter)
        heightConstraint = heightAnchor.constraint(equalToConstant: diameter)
        widthConstraint?.isActive = true
        heightConstraint?.isActive = true
    }

    // MARK: - Appearance

    private func updateAppearance() {
        let diameter = size.points

        // Update size constraints
        widthConstraint?.constant = diameter
        heightConstraint?.constant = diameter

        // Shape / corner radius
        switch shape {
            case .circle:
                layer.cornerRadius = diameter / 2
            case .rounded:
                layer.cornerRadius = HABRadius.md
        }
        layer.masksToBounds = true

        // Image vs initials
        if let img = image {
            imageView.image = img
            imageView.isHidden = false
            initialsLabel.isHidden = true
            backgroundColor = .habSurface
        } else {
            imageView.isHidden = true
            imageView.image = nil
            initialsLabel.isHidden = false
            initialsLabel.text = initials(from: name)
            initialsLabel.font = initialsFont(for: size)
            initialsLabel.textColor = .habPrimary
            backgroundColor = .habPrimary.withAlphaComponent(0.12)
        }

        // Accessibility
        isAccessibilityElement = true
        accessibilityLabel = name ?? "Avatar"
        accessibilityTraits = [.image]
    }

    // MARK: - Helpers

    private func initials(from name: String?) -> String {
        guard let name = name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "?"
        }
        let words = name.split(separator: " ").map(String.init)
        let letters = words.prefix(2).compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased()
    }

    private func initialsFont(for size: Size) -> UIFont {
        switch size {
            case .small:
                return .habFootnote
            case .medium:
                return .habBody
            case .large:
                return UIFont.systemFont(ofSize: 20, weight: .semibold) // habTitle3 approximation
        }
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
