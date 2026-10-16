//
//  HABFormSection.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A group of form rows: an optional header, a card holding the rows, and an optional footer.
///
/// ## Overview
///
/// Stack sections vertically in a scroll view to build a form:
///
/// ```swift
/// let schedule = HABFormSection(
///     header: "Schedule",
///     footer: "Doses are scheduled in your current time zone.",
///     rows: [
///         HABFormRow(label: "Starts", control: startPicker),
///         HABFormRow(label: "Repeat", control: repeatButton),
///         HABFormRow(content: HABStepper(value: 1, minimumValue: 1, maximumValue: 30, labelFormatter: { "Every \(Int($0)) days" }))
///     ]
/// )
/// formStack.addArrangedSubview(schedule)
/// ```
///
/// Rows are usually ``HABFormRow``s, but any view works; it should bring its own padding.
///
/// ## Dividers
///
/// A divider separates each pair of *visible* rows. Hide a row with `isHidden` and the
/// dividers rearrange on the next layout pass; when every row is hidden the card hides too.
/// If you hide a row without anything else changing size, call ``updateDividers()``.
///
/// ## Topics
///
/// ### Creating a Section
/// - ``init(header:headerDetail:footer:rows:cardStyle:)``
///
/// ### Header and Footer
/// - ``header``
/// - ``headerDetail``
/// - ``footer``
///
/// ### Managing Rows
/// - ``rows``
/// - ``addRow(_:)``
/// - ``insertRow(_:at:)``
/// - ``removeRow(_:)``
/// - ``updateDividers()``
public final class HABFormSection: UIView {
    // MARK: - Public Properties

    /// Text above the card.
    public var header: String? { didSet { updateHeaderAndFooter() } }

    /// Optional trailing text in the header, e.g. "3 of 4 taken".
    public var headerDetail: String? { didSet { updateHeaderAndFooter() } }

    /// Text below the card.
    public var footer: String? { didSet { updateHeaderAndFooter() } }

    /// The rows, in order.
    public private(set) var rows: [UIView] = []

    // MARK: - Private

    private let headerView = HABSectionTitleView(kind: .header)
    private let footerView = HABSectionTitleView(kind: .footer)
    private let card: HABCard
    private let rowsStack = UIStackView()
    private let outerStack = UIStackView()

    /// `dividers[i]` sits directly above `rows[i]`; `dividers[0]` is never shown.
    private var dividers: [UIView] = []

    // MARK: - Init

    /// Creates a form section.
    ///
    /// - Parameters:
    ///   - header: Text above the card.
    ///   - headerDetail: Optional trailing text in the header.
    ///   - footer: Text below the card.
    ///   - rows: The rows, top to bottom.
    ///   - cardStyle: The card's style. Defaults to `.flat`, a surface-colored rounded card.
    public init(
        header: String? = nil,
        headerDetail: String? = nil,
        footer: String? = nil,
        rows: [UIView] = [],
        cardStyle: HABCard.Style = .flat
    ) {
        self.header = header
        self.headerDetail = headerDetail
        self.footer = footer
        self.card = HABCard(style: cardStyle)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        rows.forEach { addRow($0) }
        updateHeaderAndFooter()
        updateDividers()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        rowsStack.axis = .vertical
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rowsStack)
        NSLayoutConstraint.activate([
            rowsStack.topAnchor.constraint(equalTo: card.topAnchor),
            rowsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            rowsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            rowsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor)
        ])

        outerStack.axis = .vertical
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.addArrangedSubview(headerView)
        outerStack.addArrangedSubview(card)
        outerStack.addArrangedSubview(footerView)
        addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Rows

    /// Adds a row at the bottom of the card.
    public func addRow(_ row: UIView) {
        insertRow(row, at: rows.count)
    }

    /// Inserts a row at `index` (clamped to the valid range).
    public func insertRow(_ row: UIView, at index: Int) {
        if rows.contains(where: { $0 === row }) { removeRow(row) }
        let index = max(0, min(index, rows.count))
        let divider = Self.makeDivider()
        rows.insert(row, at: index)
        dividers.insert(divider, at: index)
        // Each row is preceded by its divider in the stack: [d0, r0, d1, r1, ...].
        rowsStack.insertArrangedSubview(row, at: index * 2)
        rowsStack.insertArrangedSubview(divider, at: index * 2)
        updateDividers()
    }

    /// Removes a row from the card.
    public func removeRow(_ row: UIView) {
        guard let index = rows.firstIndex(where: { $0 === row }) else { return }
        let divider = dividers[index]
        rows.remove(at: index)
        dividers.remove(at: index)
        row.removeFromSuperview()
        divider.removeFromSuperview()
        updateDividers()
    }

    /// Shows a divider above each visible row that has a visible row somewhere above it,
    /// and hides the card when no row is visible.
    public func updateDividers() {
        var seenVisibleRow = false
        for (row, divider) in zip(rows, dividers) {
            let showsDivider = !row.isHidden && seenVisibleRow
            if divider.isHidden != !showsDivider { divider.isHidden = !showsDivider }
            if !row.isHidden { seenVisibleRow = true }
        }
        if card.isHidden != !seenVisibleRow { card.isHidden = !seenVisibleRow }
    }

    public override func layoutSubviews() {
        // Rows hidden since the last pass change the stack's height, which lands here.
        updateDividers()
        super.layoutSubviews()
    }

    private static func makeDivider() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isAccessibilityElement = false
        let divider = HABDivider()
        container.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: container.topAnchor),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            // Inset to line up with the row text, like grouped table separators.
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: HABSpacing.md),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }

    // MARK: - Header and Footer

    private func updateHeaderAndFooter() {
        headerView.text = header
        headerView.detail = headerDetail
        headerView.isHidden = (header?.isEmpty ?? true) && (headerDetail?.isEmpty ?? true)
        footerView.text = footer
        footerView.isHidden = footer?.isEmpty ?? true
    }
}
