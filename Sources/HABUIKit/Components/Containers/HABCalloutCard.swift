//
//  HABCalloutCard.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A tinted card with a colored bar along its leading edge, for status and callouts:
/// a block on a day timeline, a reminder, a note that needs attention.
///
/// ## Overview
///
/// ```swift
/// let morning = HABCalloutCard(
///     tone: .success,
///     title: "8:00 AM · Morning",
///     message: "Lisinopril, Metformin — all taken",
///     icon: UIImage(systemName: "sun.max")
/// )
/// ```
///
/// Give it an ``action`` to make the whole card tappable; it then highlights while pressed
/// and VoiceOver reads it as a button named by the title and message. Without an action it
/// reads as text.
///
/// Unlike ``HABBanner``, a callout card doesn't announce itself or offer dismissal; it's
/// part of the page's content.
///
/// ## Topics
///
/// ### Creating a Callout Card
/// - ``init(tone:title:message:icon:action:)``
///
/// ### Content
/// - ``title``
/// - ``message``
/// - ``icon``
///
/// ### Appearance
/// - ``tone``
/// - ``Tone``
///
/// ### Interaction
/// - ``action``
public final class HABCalloutCard: UIControl {
    // MARK: - Types

    /// The card's color: a tinted background and a solid leading bar.
    public enum Tone {
        case primary
        case info
        case success
        case warning
        case destructive
        /// The surface color with a border-colored bar.
        case neutral
    }

    // MARK: - Public Properties

    /// The color role.
    public var tone: Tone { didSet { updateAppearance() } }

    /// Bold first line.
    public var title: String? { didSet { updateAppearance() } }

    /// Secondary text under the title.
    public var message: String? { didSet { updateAppearance() } }

    /// Optional icon at the leading edge, tinted with the tone color.
    public var icon: UIImage? { didSet { updateAppearance() } }

    /// When set, the card is tappable and runs this action. Its label is used as a VoiceOver hint
    /// only if it differs from the title, since the card is already named by its text.
    public var action: HABAccessibleAction? { didSet { updateAppearance() } }

    public override var isHighlighted: Bool {
        didSet { updatePressedState() }
    }

    // MARK: - Private

    private let accentBar = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let textStack = UIStackView()
    private let contentStack = UIStackView()

    private static let barWidth: CGFloat = 4

    // MARK: - Init

    /// Creates a callout card.
    ///
    /// - Parameters:
    ///   - tone: The color role. Defaults to `.primary`.
    ///   - title: Bold first line.
    ///   - message: Secondary text.
    ///   - icon: Optional leading icon.
    ///   - action: Makes the card tappable when set.
    public init(
        tone: Tone = .primary,
        title: String? = nil,
        message: String? = nil,
        icon: UIImage? = nil,
        action: HABAccessibleAction? = nil
    ) {
        self.tone = tone
        self.title = title
        self.message = message
        self.icon = icon
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        updateAppearance()
        addTarget(self, action: #selector(tapped), for: .touchUpInside)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        clipsToBounds = true

        accentBar.translatesAutoresizingMaskIntoConstraints = false
        accentBar.isUserInteractionEnabled = false
        addSubview(accentBar)

        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline)
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        [titleLabel, messageLabel].forEach {
            $0.numberOfLines = 0
            $0.adjustsFontForContentSizeCategory = true
        }

        textStack.axis = .vertical
        textStack.spacing = HABSpacing.xxs
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(messageLabel)

        contentStack.axis = .horizontal
        contentStack.alignment = .top
        contentStack.spacing = HABSpacing.sm
        contentStack.isUserInteractionEnabled = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(textStack)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            accentBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            accentBar.topAnchor.constraint(equalTo: topAnchor),
            accentBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            accentBar.widthAnchor.constraint(equalToConstant: Self.barWidth),

            contentStack.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: HABSpacing.md - Self.barWidth),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -HABSpacing.md),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: HABSpacing.sm + HABSpacing.xs),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(HABSpacing.sm + HABSpacing.xs))
        ])

        isAccessibilityElement = true
    }

    // MARK: - Appearance

    private var toneColor: UIColor {
        switch tone {
            case .primary: return .habPrimary
            case .info: return .habInfo
            case .success: return .habSuccess
            case .warning: return .habWarning
            case .destructive: return .habDestructive
            case .neutral: return .habBorder
        }
    }

    private var toneBackground: UIColor {
        switch tone {
            case .primary: return .habPrimary.withAlphaComponent(0.12)
            case .info: return .habInfoSurface
            case .success: return .habSuccessSurface
            case .warning: return .habWarningSurface
            case .destructive: return .habDestructiveSurface
            case .neutral: return .habSurface
        }
    }

    private func updateAppearance() {
        layer.cornerRadius = habTheme.radius.md
        backgroundColor = toneBackground
        accentBar.backgroundColor = toneColor

        titleLabel.text = title
        titleLabel.isHidden = title?.isEmpty ?? true
        titleLabel.font = .habHeadline
        titleLabel.textColor = .habForeground

        messageLabel.text = message
        messageLabel.isHidden = message?.isEmpty ?? true
        messageLabel.font = .habSubheadline
        messageLabel.textColor = .habForegroundSecondary

        iconView.image = icon
        iconView.isHidden = icon == nil
        // A neutral bar uses the border color, which is too faint for an icon.
        iconView.tintColor = tone == .neutral ? .habForegroundSecondary : toneColor

        isUserInteractionEnabled = action != nil
        accessibilityLabel = [title, message].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        accessibilityTraits = action == nil ? .staticText : .button
        accessibilityHint = action.flatMap { $0.label != title ? $0.label : nil }
        updatePressedState()
    }

    private func updatePressedState() {
        alpha = isHighlighted ? 0.7 : 1
    }

    // MARK: - Actions

    @objc private func tapped() {
        action?.action()
    }

    public override func accessibilityActivate() -> Bool {
        guard let action else { return false }
        action.action()
        return true
    }

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
