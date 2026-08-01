//
//  CatalogViewController.swift
//  HABUIKitSample
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation
import HABUIKit

class CatalogViewController: UITableViewController {
    private struct Section {
        let title: String
        let items: [Item]
    }

    private struct Item {
        let title: String
        let subtitle: String
        let destination: () -> UIViewController
    }

    private struct SearchResult {
        let sectionTitle: String
        let item: Item
    }

    private lazy var sections: [Section] = [
        Section(title: "Foundation", items: [
            Item(title: "Colors", subtitle: "Semantic color tokens", destination: { FoundationViewController(section: .colors) }),
            Item(title: "Typography", subtitle: "Type scale and text styles", destination: { FoundationViewController(section: .typography) }),
            Item(title: "Spacing & Radius", subtitle: "Layout constants", destination: { FoundationViewController(section: .spacing) })
        ]),
        Section(title: "Display", items: [
            Item(title: "Label", subtitle: "HABLabel — text style, mode, alignment", destination: { HABLabelDemoViewController() }),
            Item(title: "Tag", subtitle: "HABTag — style, color, dot, dismiss", destination: { HABTagDemoViewController() }),
            Item(title: "Badge", subtitle: "HABBadge — count overlay", destination: { HABBadgeDemoViewController() }),
            Item(title: "Avatar", subtitle: "HABAvatar — size, shape, image/initials", destination: { HABAvatarDemoViewController() })
        ]),
        Section(title: "Inputs", items: [
            Item(title: "Text Field", subtitle: "HABTextField — style, icons, state", destination: { HABTextFieldDemoViewController() }),
            Item(title: "Text View", subtitle: "HABTextView — multiline input", destination: { HABTextViewDemoViewController() })
        ]),
        Section(title: "Selection", items: [
            Item(title: "Toggle", subtitle: "HABToggle — label, position, state", destination: { HABToggleDemoViewController() }),
            Item(title: "Segmented Control", subtitle: "HABSegmentedControl — items", destination: { HABSegmentedControlDemoViewController() })
        ]),
        Section(title: "Buttons", items: [
            Item(title: "Button", subtitle: "HABButton — style, size, icon, state", destination: { HABButtonDemoViewController() }),
            Item(title: "Card Button", subtitle: "HABCardButton — tile with icon and subtitle", destination: { HABCardButtonDemoViewController() })
        ]),
        Section(title: "Containers", items: [
            Item(title: "Card", subtitle: "HABCard — elevated, outlined, flat", destination: { HABCardDemoViewController() }),
            Item(title: "Divider", subtitle: "HABDivider — horizontal, vertical", destination: { HABDividerDemoViewController() })
        ]),
        Section(title: "Feedback", items: [
            Item(title: "Toast", subtitle: "HABToast — temporary overlay", destination: { HABToastDemoViewController() }),
            Item(title: "Banner", subtitle: "HABBanner — inline notification", destination: { HABBannerDemoViewController() }),
            Item(title: "Loading", subtitle: "HABLoadingView — spinner + progress", destination: { HABLoadingViewDemoViewController() }),
            Item(title: "Empty State", subtitle: "HABEmptyState — icon, message, action", destination: { HABEmptyStateDemoViewController() })
        ]),
        Section(title: "Settings", items: [
            Item(title: "Theme", subtitle: "Switch active theme at runtime", destination: { ThemeSwitcherViewController() })
        ])
    ]

    private var searchResults: [SearchResult] = []
    private var isSearching: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HABUIKit"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        applyTheme()
        setupSearch()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        applyTheme()
        tableView.reloadData()
    }

    private func applyTheme() {
        tableView.backgroundColor = .habBackground
    }

    // MARK: - Search Setup

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search components"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    // MARK: - Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        isSearching ? 1 : sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? searchResults.count : sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isSearching ? nil : sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let title: String
        let subtitle: String

        if isSearching {
            let result = searchResults[indexPath.row]
            title = result.item.title
            subtitle = result.sectionTitle + " — " + result.item.subtitle
        } else {
            let item = sections[indexPath.section].items[indexPath.row]
            title = item.title
            subtitle = item.subtitle
        }

        var config = UIListContentConfiguration.subtitleCell()
        config.text = title
        config.textProperties.color = .habForeground
        config.secondaryText = subtitle
        config.secondaryTextProperties.color = .habForegroundSecondary
        cell.contentConfiguration = config
        cell.backgroundColor = .habSurface
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destination: UIViewController
        if isSearching {
            destination = searchResults[indexPath.row].item.destination()
        } else {
            destination = sections[indexPath.section].items[indexPath.row].destination()
        }
        navigationController?.pushViewController(destination, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchResults = sections.flatMap { section in
            section.items
                .filter { item in
                    item.title.localizedCaseInsensitiveContains(query) ||
                    item.subtitle.localizedCaseInsensitiveContains(query) ||
                    section.title.localizedCaseInsensitiveContains(query)
                }
                .map { SearchResult(sectionTitle: section.title, item: $0) }
        }
        tableView.reloadData()
    }
}
