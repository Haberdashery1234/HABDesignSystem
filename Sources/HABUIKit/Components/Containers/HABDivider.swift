//
//  HABDivider.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public final class HABDivider: UIView {
    // MARK: - Public Types

    public enum Axis {
        case horizontal
        case vertical
    }

    // MARK: - Public Properties

    public var axis: Axis {
        didSet { updateAppearance() }
    }

    // MARK: - Init

    public init(axis: Axis = .horizontal) {
        self.axis = axis
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        // Set content hugging so the thin dimension resists expansion
        setContentHuggingPriority(.required, for: axis == .horizontal ? .vertical : .horizontal)

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

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        switch axis {
            case .horizontal:
                return CGSize(width: UIView.noIntrinsicMetric, height: 0.5)
            case .vertical:
                return CGSize(width: 0.5, height: UIView.noIntrinsicMetric)
        }
    }

    // MARK: - Appearance

    private func updateAppearance() {
        backgroundColor = .habBorderSubtle

        // Update hugging priority for the thin dimension
        setContentHuggingPriority(.required, for: axis == .horizontal ? .vertical : .horizontal)
        setContentHuggingPriority(.defaultLow, for: axis == .horizontal ? .horizontal : .vertical)

        invalidateIntrinsicContentSize()
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
