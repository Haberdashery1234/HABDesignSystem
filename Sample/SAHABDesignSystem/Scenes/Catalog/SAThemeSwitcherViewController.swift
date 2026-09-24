//
//  SAThemeSwitcherViewController.swift
//  SAHABDesignSystem
//
//  Lets you switch the active HABUIKit theme at runtime.
//  The entire app re-renders immediately when a theme is selected
//  because all HABUIKit components observe themeDidChangeNotification.
//

import UIKit
import HABFoundation
import HABUIKit

// MARK: - ThemeOption

/// Pairs a theme with the description shown on its card.
/// Declared at file scope so ThemeCardView can reference it.
private struct ThemeOption {
    let theme: any HABTheme
    let description: String
}

// MARK: - SAThemeSwitcherViewController

class SAThemeSwitcherViewController: UIViewController {
    private let options: [ThemeOption] = [
        ThemeOption(
            theme: HABLightTheme(),
            description: "Parchment backgrounds · Royal Blue primary · Antique Gold accent"
        ),
        ThemeOption(
            theme: HABDarkTheme(),
            description: "Deep navy backgrounds · Brightened Royal Blue · Parchment text"
        ),
        ThemeOption(
            theme: HABAppleTheme(),
            description: "Apple system colors · Adapts automatically to system appearance"
        )
    ]

    private let scrollView = UIScrollView()
    private let stackView  = UIStackView()
    private var cardViews: [ThemeCardView] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Theme"
        view.backgroundColor = .habBackground
        setupLayout()
        buildCards()
        observeThemeChanges()
    }

    // MARK: - Layout

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

    // MARK: - Cards

    private func buildCards() {
        let activeName = HABThemeManager.shared.theme.name
        cardViews = options.map { option in
            let card = ThemeCardView(option: option, isActive: option.theme.name == activeName)
            card.onTap = { [weak self] in self?.apply(option.theme) }
            return card
        }
        cardViews.forEach { stackView.addArrangedSubview($0) }
    }

    private func apply(_ theme: any HABTheme) {
        HABThemeManager.shared.theme = theme
    }

    private func refreshActiveState() {
        let activeName = HABThemeManager.shared.theme.name
        zip(options, cardViews).forEach { option, card in
            card.setActive(option.theme.name == activeName)
        }
    }

    // MARK: - Notifications

    private func observeThemeChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    @objc private func themeDidChange() {
        view.backgroundColor = .habBackground
        refreshActiveState()
    }
}

// MARK: - ThemeCardView

private final class ThemeCardView: UIView {
    var onTap: (() -> Void)?

    private let card        = HABCard(style: .outlined)
    private let nameLabel   = HABLabel(textStyle: .headline)
    private let descLabel   = HABLabel(textStyle: .footnote)
    private let swatchStack = UIStackView()
    private let checkmark   = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))

    init(option: ThemeOption, isActive: Bool) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupCard(option: option)
        setActive(isActive)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCard(option: ThemeOption) {
        let colors = option.theme.colors

        // Card fills self
        addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        nameLabel.text = option.theme.name
        descLabel.text = option.description
        descLabel.numberOfLines = 0

        // Color swatches: primary · background · surface · foreground
        swatchStack.axis = .horizontal
        swatchStack.spacing = HABSpacing.xs
        swatchStack.translatesAutoresizingMaskIntoConstraints = false

        for color in [colors.primary, colors.background, colors.surface, colors.foreground] {
            swatchStack.addArrangedSubview(makeSwatch(color: color))
        }

        // Checkmark
        checkmark.tintColor = .habPrimary
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.contentMode = .scaleAspectFit

        let contentStack = UIStackView(arrangedSubviews: [nameLabel, descLabel, swatchStack])
        contentStack.axis = .vertical
        contentStack.spacing = HABSpacing.xs
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(contentStack)
        card.addSubview(checkmark)

        let p = CGFloat(HABSpacing.md)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: p),
            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: p),
            contentStack.trailingAnchor.constraint(equalTo: checkmark.leadingAnchor, constant: -CGFloat(HABSpacing.sm)),
            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -p),

            checkmark.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -p),
            checkmark.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 24),
            checkmark.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func makeSwatch(color: UIColor) -> UIView {
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = color
        circle.layer.cornerRadius = 10
        circle.layer.borderWidth = 1
        circle.layer.borderColor = UIColor.habBorder.cgColor
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 20),
            circle.heightAnchor.constraint(equalToConstant: 20)
        ])
        return circle
    }

    func setActive(_ active: Bool) {
        checkmark.isHidden = !active
        card.style = active ? .elevated : .outlined
    }

    @objc private func tapped() {
        onTap?()
    }
}
