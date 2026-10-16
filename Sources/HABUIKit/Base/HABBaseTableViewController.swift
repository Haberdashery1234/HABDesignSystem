//
//  HABBaseTableViewController.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit
import HABFoundation

/// A UITableViewController subclass that automatically applies theme colors
/// to the view and table view, and re-applies them when the theme changes.
///
/// Colors assigned from `UIColor.hab*` update on their own when the theme changes
/// (they're dynamic; see `HABThemeTrait`). Override `themeDidChange()` for things that
/// don't: fonts, layer `CGColor`s, and radius/shadow tokens.
///
/// ```swift
/// override func themeDidChange() {
///     super.themeDidChange()
///     titleLabel.font = .habHeadline
///     cardView.layer.borderColor = UIColor.habBorder.resolvedColor(with: traitCollection).cgColor
/// }
/// ```
///
/// ## Empty State
///
/// Set ``emptyState`` and the controller places it behind the rows, centered in the
/// table. Show it when there's nothing to list:
///
/// ```swift
/// emptyState = HABEmptyState(
///     title: "No medications",
///     message: "Add a medication to see it here.",
///     icon: UIImage(systemName: "pills")
/// )
///
/// func reload() {
///     tableView.reloadData()
///     updateEmptyStateVisibility()   // shows it when every section has 0 rows
/// }
/// ```
///
/// Use ``setEmptyStateVisible(_:animated:)`` instead when "empty" means something other
/// than zero rows, e.g. a table that always has a header section.
///
/// ## Floating Action Button
///
/// Set ``floatingActionButton`` to pin an ``HABFloatingActionButton`` to the bottom
/// trailing corner. It stays put while the rows scroll, and the table gets enough bottom
/// inset that the last row can scroll clear of it.
open class HABBaseTableViewController: UITableViewController {
    // MARK: - Empty State

    /// A view shown behind the rows while ``isEmptyStateVisible`` is `true`.
    ///
    /// The controller installs it as the table's `backgroundView`. Setting it doesn't
    /// show it; call ``updateEmptyStateVisibility(animated:)`` or
    /// ``setEmptyStateVisible(_:animated:)``.
    public var emptyState: HABEmptyState? {
        didSet {
            guard emptyState !== oldValue else { return }
            oldValue?.removeFromSuperview()
            if emptyState == nil, wantsEmptyStateVisible {
                // Removed while showing: undo what showing it changed.
                wantsEmptyStateVisible = false
                emptyStateContainer.isHidden = true
                if let previous = separatorStyleBeforeEmptyState, isViewLoaded {
                    tableView.separatorStyle = previous
                }
                separatorStyleBeforeEmptyState = nil
            }
            if isViewLoaded { installEmptyState() }
        }
    }

    /// Whether the empty state is showing. Setting this shows or hides it without animation.
    public var isEmptyStateVisible: Bool {
        get { emptyState != nil && wantsEmptyStateVisible }
        set { setEmptyStateVisible(newValue, animated: false) }
    }

    private let emptyStateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    /// The requested visibility. Differs from `emptyStateContainer.isHidden` mid-fade.
    private var wantsEmptyStateVisible = false

    /// The separator style to restore when the empty state hides.
    private var separatorStyleBeforeEmptyState: UITableViewCell.SeparatorStyle?

    // MARK: - Floating Action Button

    /// A button pinned to the bottom trailing corner that doesn't scroll with the rows.
    public var floatingActionButton: HABFloatingActionButton? {
        didSet {
            guard floatingActionButton !== oldValue else { return }
            oldValue?.uninstall()
            if isViewLoaded, let floatingActionButton {
                floatingActionButton.install(in: tableView)
            }
        }
    }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
        installEmptyState()
        if let floatingActionButton, floatingActionButton.superview == nil {
            floatingActionButton.install(in: tableView)
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Cells are added to the table as it scrolls; keep the button above them.
        floatingActionButton?.updatePlacement()
    }

    // MARK: - Empty State

    /// Shows or hides the empty state.
    ///
    /// - Parameters:
    ///   - visible: `true` to show it.
    ///   - animated: Whether to fade it in or out.
    public func setEmptyStateVisible(_ visible: Bool, animated: Bool = false) {
        guard let emptyState, visible != wantsEmptyStateVisible else { return }
        wantsEmptyStateVisible = visible

        if visible {
            if separatorStyleBeforeEmptyState == nil {
                separatorStyleBeforeEmptyState = tableView.separatorStyle
            }
            // Plain tables draw separators for empty rows, which would cross the empty state.
            tableView.separatorStyle = .none
        } else if let previous = separatorStyleBeforeEmptyState {
            tableView.separatorStyle = previous
            separatorStyleBeforeEmptyState = nil
        }

        let container = emptyStateContainer
        if animated {
            if visible {
                container.alpha = 0
                container.isHidden = false
            }
            UIView.animate(
                withDuration: habTheme.motion.normal,
                animations: { container.alpha = visible ? 1 : 0 },
                completion: { _ in
                    // Skip if it was shown again while fading out.
                    if !visible, container.alpha == 0 { container.isHidden = true }
                }
            )
        } else {
            container.alpha = 1
            container.isHidden = !visible
        }

        if visible {
            // Move VoiceOver to the empty state so users hear why the list is blank.
            UIAccessibility.post(notification: .layoutChanged, argument: emptyState)
        }
    }

    /// Shows the empty state when every section has zero rows, and hides it otherwise.
    ///
    /// Call it after `reloadData()` or after inserting or deleting rows.
    public func updateEmptyStateVisibility(animated: Bool = false) {
        let sectionCount = tableView.numberOfSections
        let isEmpty = (0..<sectionCount).allSatisfy { tableView.numberOfRows(inSection: $0) == 0 }
        setEmptyStateVisible(isEmpty, animated: animated)
    }

    private func installEmptyState() {
        guard let emptyState else { return }
        if tableView.backgroundView !== emptyStateContainer {
            tableView.backgroundView = emptyStateContainer
        }
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainer.addSubview(emptyState)
        let guide = emptyStateContainer.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            emptyState.topAnchor.constraint(equalTo: guide.topAnchor),
            emptyState.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            emptyState.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
    }

    // MARK: - Appearance

    private func updateAppearance() {
        view.backgroundColor = .habBackground
        tableView.backgroundColor = .habBackground
        tableView.separatorColor = .habBorderSubtle
        themeDidChange()
    }

    // MARK: - Theme

    /// Called whenever the active theme changes (on the main thread). Override to
    /// re-apply fonts, `CGColor`s and radius/shadow tokens. Always call super.
    @objc open func themeDidChange() {}

    @objc private func handleThemeChange() {
        view.backgroundColor = .habBackground
        tableView.backgroundColor = .habBackground
        tableView.separatorColor = .habBorderSubtle
        themeDidChange()
    }
}
