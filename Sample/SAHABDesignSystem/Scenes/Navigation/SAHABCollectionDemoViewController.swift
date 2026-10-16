//
//  SAHABCollectionDemoViewController.swift
//  SAHABDesignSystem
//
//  HABBaseCollectionViewController: a grid of the active theme's color tokens.
//  Switch themes with the palette button to watch it update.
//

import UIKit
import HABFoundation
import HABUIKit

final class SAHABCollectionDemoViewController: HABBaseCollectionViewController {
    private struct Swatch {
        let name: String
        let color: UIColor
    }

    private let swatches: [Swatch] = [
        Swatch(name: "primary", color: .habPrimary),
        Swatch(name: "secondary", color: .habSecondary),
        Swatch(name: "accent", color: .habAccent),
        Swatch(name: "surface", color: .habSurface),
        Swatch(name: "foreground", color: .habForeground),
        Swatch(name: "foregroundSecondary", color: .habForegroundSecondary),
        Swatch(name: "success", color: .habSuccess),
        Swatch(name: "warning", color: .habWarning),
        Swatch(name: "destructive", color: .habDestructive),
        Swatch(name: "info", color: .habInfo),
        Swatch(name: "border", color: .habBorder),
        Swatch(name: "overlay", color: .habOverlay)
    ]

    init() {
        super.init(collectionViewLayout: Self.makeLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Collection View"
        collectionView.register(SASwatchCell.self, forCellWithReuseIdentifier: SASwatchCell.reuseIdentifier)
    }

    override func themeDidChange() {
        super.themeDidChange()
        // Colors update on their own; fonts and the layer border don't.
        collectionView?.reloadData()
    }

    private static func makeLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(120))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120)),
            repeatingSubitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(HABSpacing.md)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = HABSpacing.md
        section.contentInsets = NSDirectionalEdgeInsets(
            top: HABSpacing.md, leading: HABSpacing.md, bottom: HABSpacing.md, trailing: HABSpacing.md
        )
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Data Source

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        swatches.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SASwatchCell.reuseIdentifier, for: indexPath)
        let swatch = swatches[indexPath.item]
        (cell as? SASwatchCell)?.configure(name: swatch.name, color: swatch.color)
        return cell
    }
}

/// A rounded color sample with the token name under it.
private final class SASwatchCell: UICollectionViewCell {
    static let reuseIdentifier = "SASwatchCell"

    private let swatch = UIView()
    private let nameLabel = HABLabel(textStyle: .footnote)

    override init(frame: CGRect) {
        super.init(frame: frame)
        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.layer.cornerRadius = HABRadius.md
        swatch.layer.borderWidth = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        contentView.addSubview(swatch)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            swatch.topAnchor.constraint(equalTo: contentView.topAnchor),
            swatch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            swatch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            swatch.heightAnchor.constraint(equalToConstant: 72),
            nameLabel.topAnchor.constraint(equalTo: swatch.bottomAnchor, constant: HABSpacing.xs),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, color: UIColor) {
        swatch.backgroundColor = color
        swatch.layer.borderColor = UIColor.habBorderSubtle.resolvedColor(with: traitCollection).cgColor
        nameLabel.text = name
        accessibilityLabel = name
    }
}
