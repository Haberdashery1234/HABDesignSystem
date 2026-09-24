//
//  SAFoundationViewController.swift
//  SAHABDesignSystem
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation
import HABUIKit

class SAFoundationViewController: HABBaseViewController {
    enum Section {
        case colors, typography, spacing
    }

    private let section: Section
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    init(section: Section) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        switch section {
            case .colors:
                title = "Colors";           addColorSamples()
            case .typography:
                title = "Typography";       addTypographySamples()
            case .spacing:
                title = "Spacing & Radius"; addSpacingSamples()
        }
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = HABSpacing.md
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

    // MARK: - Colors

    private func addColorSamples() {
        let tokens: [(String, UIColor)] = [
            ("primary", .habPrimary),
            ("secondary", .habSecondary),
            ("accent", .habAccent),
            ("background", .habBackground),
            ("backgroundSecondary", .habBackgroundSecondary),
            ("surface", .habSurface),
            ("surfaceElevated", .habSurfaceElevated),
            ("foreground", .habForeground),
            ("foregroundSecondary", .habForegroundSecondary),
            ("foregroundTertiary", .habForegroundTertiary),
            ("foregroundDisabled", .habForegroundDisabled),
            ("destructive", .habDestructive),
            ("success", .habSuccess),
            ("warning", .habWarning),
            ("info", .habInfo),
            ("border", .habBorder),
            ("borderSubtle", .habBorderSubtle)
        ]

        addHeader("Brand & Semantic Colors")
        for (name, color) in tokens {
            stackView.addArrangedSubview(colorRow(name: name, color: color))
        }
    }

    private func colorRow(name: String, color: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = HABSpacing.md
        row.alignment = .center

        let swatch = UIView()
        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.backgroundColor = color
        swatch.layer.cornerRadius = HABRadius.xs
        swatch.layer.borderWidth = 0.5
        swatch.layer.borderColor = UIColor.habBorder.cgColor
        NSLayoutConstraint.activate([
            swatch.widthAnchor.constraint(equalToConstant: 44),
            swatch.heightAnchor.constraint(equalToConstant: 44)
        ])

        let label = UILabel()
        label.text = name
        label.font = .habBody
        label.textColor = .habForeground

        row.addArrangedSubview(swatch)
        row.addArrangedSubview(label)
        return row
    }

    // MARK: - Typography

    private func addTypographySamples() {
        let samples: [(String, UIFont)] = [
            ("display — 40pt", .habDisplay),
            ("largeTitle — 34pt", .habLargeTitle),
            ("title1 — 28pt", .habTitle1),
            ("title2 — 22pt", .habTitle2),
            ("title3 — 20pt", .habTitle3),
            ("headline — 17pt semibold", .habHeadline),
            ("body — 17pt", .habBody),
            ("callout — 16pt", .habCallout),
            ("subheadline — 15pt", .habSubheadline),
            ("footnote — 13pt", .habFootnote),
            ("caption1 — 12pt", .habCaption1),
            ("caption2 — 11pt", .habCaption2)
        ]

        addHeader("Type Scale")
        for (text, font) in samples {
            let label = UILabel()
            label.text = text
            label.font = font
            label.textColor = .habForeground
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
    }

    // MARK: - Spacing & Radius

    private func addSpacingSamples() {
        addHeader("Spacing")
        let spacings: [(String, CGFloat)] = [
            ("xxs — 2pt", HABSpacing.xxs),
            ("xs — 4pt", HABSpacing.xs),
            ("sm — 8pt", HABSpacing.sm),
            ("md — 16pt", HABSpacing.md),
            ("lg — 24pt", HABSpacing.lg),
            ("xl — 32pt", HABSpacing.xl),
            ("xxl — 48pt", HABSpacing.xxl)
        ]
        for (name, size) in spacings {
            stackView.addArrangedSubview(spacingRow(name: name, size: size))
        }

        addHeader("Corner Radius")
        let radii: [(String, CGFloat)] = [
            ("xs — 4pt", HABRadius.xs),
            ("sm — 8pt", HABRadius.sm),
            ("md — 12pt", HABRadius.md),
            ("lg — 16pt", HABRadius.lg),
            ("xl — 24pt", HABRadius.xl),
            ("pill — 9999pt", HABRadius.pill)
        ]
        for (name, radius) in radii {
            stackView.addArrangedSubview(radiusRow(name: name, radius: radius))
        }
    }

    private func spacingRow(name: String, size: CGFloat) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = HABSpacing.md
        row.alignment = .center

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .habPrimary
        bar.layer.cornerRadius = 2
        NSLayoutConstraint.activate([
            bar.widthAnchor.constraint(equalToConstant: min(size * 2, 200)),
            bar.heightAnchor.constraint(equalToConstant: 20)
        ])

        let label = UILabel()
        label.text = name
        label.font = .habBody
        label.textColor = .habForeground

        row.addArrangedSubview(bar)
        row.addArrangedSubview(label)
        return row
    }

    private func radiusRow(name: String, radius: CGFloat) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = HABSpacing.md
        row.alignment = .center

        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = .habSurface
        box.layer.borderColor = UIColor.habPrimary.cgColor
        box.layer.borderWidth = 1.5
        box.layer.cornerRadius = min(radius, 22)
        NSLayoutConstraint.activate([
            box.widthAnchor.constraint(equalToConstant: 44),
            box.heightAnchor.constraint(equalToConstant: 44)
        ])

        let label = UILabel()
        label.text = name
        label.font = .habBody
        label.textColor = .habForeground

        row.addArrangedSubview(box)
        row.addArrangedSubview(label)
        return row
    }

    // MARK: - Helpers

    private func addHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .habFootnote
        label.textColor = .secondaryLabel
        stackView.addArrangedSubview(label)
    }
}
