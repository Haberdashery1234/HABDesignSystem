//
//  HABImageView.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

/// A themed UIImageView wrapper that supports placeholder images, content modes,
/// corner radius, and automatic theme adaptation.
public final class HABImageView: UIView {
    // MARK: - Content Mode

    public enum ImageContentMode {
        case scaleAspectFill
        case scaleAspectFit
        case center

        var uiKitMode: UIView.ContentMode {
            switch self {
                case .scaleAspectFill:
                    return .scaleAspectFill
                case .scaleAspectFit:
                    return .scaleAspectFit
                case .center:
                    return .center
            }
        }
    }

    // MARK: - Public Properties

    public var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue; updatePlaceholder() }
    }

    public var placeholder: UIImage? {
        didSet { updatePlaceholder() }
    }

    /// The scaling mode applied to the wrapped image view.
    /// Named `imageContentMode` to avoid shadowing `UIView.contentMode`.
    public var imageContentMode: ImageContentMode = .scaleAspectFill {
        didSet { imageView.contentMode = imageContentMode.uiKitMode }
    }

    public var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    // MARK: - Private Properties

    private let imageView = UIImageView()

    // MARK: - Init

    public init(
        image: UIImage? = nil,
        placeholder: UIImage? = nil,
        imageContentMode: ImageContentMode = .scaleAspectFill
    ) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        self.imageContentMode = imageContentMode
        imageView.image = image ?? placeholder
        setupViews()
        updateAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = imageContentMode.uiKitMode
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Placeholder

    private func updatePlaceholder() {
        if imageView.image == nil {
            imageView.image = placeholder
        }
    }

    // MARK: - Appearance

    private func updateAppearance() {
        backgroundColor = .habSurface
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
