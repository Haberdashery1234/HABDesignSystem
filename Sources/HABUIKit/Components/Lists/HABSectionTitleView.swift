//
//  HABSectionTitleView.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// Section header or footer text in the secondary color, with an optional trailing detail
/// ("Today … 3 of 4 taken").
///
/// Use it on its own above or below a group of content (``HABFormSection`` does), or in
/// a table through ``HABSectionHeaderFooterView``.
///
/// ```swift
/// let header = HABSectionTitleView(kind: .header, text: "Today", detail: "3 of 4 taken")
/// ```
///
/// Headers are a single line of text that VoiceOver treats as a heading, so the rotor
/// can jump between sections. Footers wrap and are read as plain text.
///
/// The view pads itself with its `directionalLayoutMargins`. The defaults line the text
/// up with the content of a ``HABListCell`` or ``HABFormRow``.
///
/// ## Topics
///
/// ### Creating the View
/// - ``init(kind:text:detail:)``
///
/// ### Content
/// - ``kind``
/// - ``text``
/// - ``detail``
public final class HABSectionTitleView: UIView {
    // MARK: - Types

    /// Whether the view sits above a section or below it.
    public enum Kind {
        /// Above the section. Read as a heading by VoiceOver.
        case header
        /// Below the section. Wraps onto as many lines as it needs.
        case footer
    }

    // MARK: - Public Properties

    /// Whether this is a header or a footer. Changes padding and accessibility.
    public var kind: Kind { didSet { updateAppearance() } }

    /// The main text.
    public var text: String? { didSet { updateAppearance() } }

    /// Optional text at the trailing edge, e.g. "3 of 4 taken".
    public var detail: String? { didSet { updateAppearance() } }

    // MARK: - Private Subviews

    private let textLabel = UILabel()
    private let detailLabel = UILabel()
    private let stack = UIStackView()

    // MARK: - Init

    /// Creates a section header or footer.
    ///
    /// - Parameters:
    ///   - kind: `.header` or `.footer`. Defaults to `.header`.
    ///   - text: The main text.
    ///   - detail: Optional trailing text.
    public init(kind: Kind = .header, text: String? = nil, detail: String? = nil) {
        self.kind = kind
        self.text = text
        self.detail = detail
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        // Vertical margins depend on `kind` and are set in `updateAppearance()`.
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0, leading: HABSpacing.md, bottom: 0, trailing: HABSpacing.md
        )
        setupViews()
        updateAppearance()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.updateAxis()
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        textLabel.adjustsFontForContentSizeCategory = true
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.numberOfLines = 0
        textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        stack.spacing = HABSpacing.sm
        stack.alignment = .firstBaseline
        stack.addArrangedSubview(textLabel)
        stack.addArrangedSubview(detailLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let margins = layoutMarginsGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: margins.topAnchor),
            stack.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])

        isAccessibilityElement = true
        updateAxis()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        textLabel.text = text
        textLabel.isHidden = text?.isEmpty ?? true
        detailLabel.text = detail
        detailLabel.isHidden = detail?.isEmpty ?? true

        textLabel.font = .habFootnote
        detailLabel.font = .habFootnote
        textLabel.textColor = .habForegroundSecondary
        detailLabel.textColor = .habForegroundSecondary

        switch kind {
            case .header:
                // Headers stay on one line unless text is very large (see `updateAxis()`).
                textLabel.numberOfLines = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 0 : 1
                directionalLayoutMargins.top = HABSpacing.md
                directionalLayoutMargins.bottom = HABSpacing.sm
                accessibilityTraits = .header
            case .footer:
                textLabel.numberOfLines = 0
                directionalLayoutMargins.top = HABSpacing.sm
                directionalLayoutMargins.bottom = HABSpacing.sm
                accessibilityTraits = .staticText
        }

        accessibilityLabel = [text, detail]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    /// Puts the detail under the text at accessibility text sizes.
    private func updateAxis() {
        let isLarge = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        stack.axis = isLarge ? .vertical : .horizontal
        stack.alignment = isLarge ? .leading : .firstBaseline
        detailLabel.textAlignment = isLarge
            ? .natural
            : (effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right)
        updateAppearance()
    }

    // MARK: - Theme

    @objc private func themeDidChange() {
        updateAppearance()
    }
}

// MARK: - HABSectionHeaderFooterView

/// A table view section header or footer that shows an ``HABSectionTitleView``.
///
/// ```swift
/// tableView.register(
///     HABSectionHeaderFooterView.self,
///     forHeaderFooterViewReuseIdentifier: HABSectionHeaderFooterView.reuseIdentifier
/// )
///
/// override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
///     let header = tableView.dequeueReusableHeaderFooterView(
///         withIdentifier: HABSectionHeaderFooterView.reuseIdentifier
///     ) as? HABSectionHeaderFooterView
///     header?.configure(kind: .header, text: "Today", detail: "3 of 4 taken")
///     return header
/// }
/// ```
///
/// The text lines up with the table's content margins, so it matches the rows below it in
/// both plain and inset-grouped tables. One reuse identifier serves headers and footers.
public final class HABSectionHeaderFooterView: UITableViewHeaderFooterView {
    /// Reuse identifier to register and dequeue the view with.
    public static let reuseIdentifier = "HABSectionHeaderFooterView"

    /// The view that draws the text. Configure it directly or with ``configure(kind:text:detail:)``.
    public let titleView = HABSectionTitleView()

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .clear
        backgroundConfiguration = background

        contentView.addSubview(titleView)
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
        // The content view already supplies the horizontal margins; keep only the vertical padding.
        titleView.directionalLayoutMargins.leading = 0
        titleView.directionalLayoutMargins.trailing = 0
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets the header or footer content.
    public func configure(kind: HABSectionTitleView.Kind, text: String?, detail: String? = nil) {
        titleView.kind = kind
        titleView.text = text
        titleView.detail = detail
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        configure(kind: .header, text: nil, detail: nil)
    }
}
