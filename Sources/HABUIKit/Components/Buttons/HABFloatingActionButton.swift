//
//  HABFloatingActionButton.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// A round, elevated button that floats over a screen's content, for its main action
/// ("Add medication").
///
/// ## Overview
///
/// The button owns its size, shadow, touch area and placement. In an
/// ``HABBaseViewController`` or ``HABBaseTableViewController``, assign it and you're done:
///
/// ```swift
/// floatingActionButton = HABFloatingActionButton(
///     icon: UIImage(systemName: "plus"),
///     action: HABAccessibleAction(label: "Add Medication") { [weak self] in
///         self?.addMedication()
///     }
/// )
/// ```
///
/// Anywhere else, call ``install(in:)`` with the view to float over.
///
/// ## Placement
///
/// The button sits in the bottom trailing corner, inside the safe area. Over a scroll
/// view (including a `UITableViewController`'s table, which *is* its view), it pins to
/// the scroll view's frame so it doesn't scroll with the content, and adds bottom content
/// inset so the last row can scroll clear of it.
///
/// ## Accessibility
///
/// The action's label is the button's VoiceOver label, so an icon-only button is still
/// named. The button is 56pt, above the 44pt minimum touch target.
///
/// ## Topics
///
/// ### Creating the Button
/// - ``init(icon:title:action:)``
///
/// ### Placement
/// - ``install(in:)``
/// - ``uninstall()``
/// - ``updatePlacement()``
public final class HABFloatingActionButton: UIButton {
    // MARK: - Public Properties

    /// The image on the button.
    public var icon: UIImage? { didSet { updateAppearance() } }

    /// Optional text next to the icon. With a title, the button becomes a capsule.
    public var title: String? { didSet { updateAppearance() } }

    /// What the button does, and its VoiceOver label.
    public var action: HABAccessibleAction { didSet { updateAppearance() } }

    // MARK: - Private

    private static let size: CGFloat = 56
    private static let margin: CGFloat = HABSpacing.md

    private var placementConstraints: [NSLayoutConstraint] = []
    private var bottomConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    /// Bottom content inset this button added to a host scroll view, to remove on uninstall.
    private var addedContentInset: CGFloat = 0

    // MARK: - Init

    /// Creates a floating action button.
    ///
    /// - Parameters:
    ///   - icon: The image, usually an SF Symbol such as `plus`.
    ///   - title: Optional text shown next to the icon.
    ///   - action: The label VoiceOver reads and the closure run on tap.
    public init(icon: UIImage?, title: String? = nil, action: HABAccessibleAction) {
        self.icon = icon
        self.title = title
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        configurationUpdateHandler = { button in
            button.alpha = button.state.contains(.disabled) ? 0.4 : 1
            let isPressed = button.state.contains(.highlighted)
            if !HABAnimation.prefersReducedMotion {
                UIView.animate(withDuration: HABThemeManager.shared.theme.motion.fast) {
                    button.transform = isPressed ? CGAffineTransform(scaleX: 0.94, y: 0.94) : .identity
                }
            }
        }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Self.size),
            widthAnchor.constraint(greaterThanOrEqualToConstant: Self.size)
        ])
        updateAppearance()

        // Shadow colors are CGColors; apply them again when light/dark changes.
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.applyElevation()
        }
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

    // MARK: - Placement

    /// Adds the button to `host`, pinned to the bottom trailing corner of its safe area.
    ///
    /// When `host` is a scroll view, the button pins to the scroll view's frame instead of
    /// its content, and the scroll view gets extra bottom inset so content can scroll
    /// clear of the button.
    public func install(in host: UIView) {
        uninstall()
        host.addSubview(self)

        if let scrollView = host as? UIScrollView {
            let guide = scrollView.frameLayoutGuide
            let bottom = bottomAnchor.constraint(equalTo: guide.bottomAnchor)
            let trailing = trailingAnchor.constraint(equalTo: guide.trailingAnchor)
            bottomConstraint = bottom
            trailingConstraint = trailing
            placementConstraints = [bottom, trailing]

            addedContentInset = Self.size + Self.margin
            scrollView.contentInset.bottom += addedContentInset
        } else {
            let guide = host.safeAreaLayoutGuide
            placementConstraints = [
                bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Self.margin),
                trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Self.margin)
            ]
        }
        NSLayoutConstraint.activate(placementConstraints)
        updatePlacement()
    }

    /// Removes the button from its host and undoes any inset it added.
    public func uninstall() {
        NSLayoutConstraint.deactivate(placementConstraints)
        placementConstraints = []
        bottomConstraint = nil
        trailingConstraint = nil
        if let scrollView = superview as? UIScrollView, addedContentInset > 0 {
            scrollView.contentInset.bottom -= addedContentInset
        }
        addedContentInset = 0
        removeFromSuperview()
    }

    /// Re-applies the safe-area offsets and keeps the button above the host's other subviews.
    ///
    /// The base view controllers call this on every layout pass. Call it yourself after
    /// ``install(in:)`` if you host the button elsewhere and add subviews later (a table
    /// view adds cells as it scrolls).
    public func updatePlacement() {
        guard let host = superview else { return }
        if host.subviews.last !== self {
            host.bringSubviewToFront(self)
        }
        // Frame-pinned constraints over a scroll view don't see the safe area; add it by hand.
        if let bottomConstraint, let trailingConstraint {
            let insets = host.safeAreaInsets
            let trailingInset = effectiveUserInterfaceLayoutDirection == .rightToLeft ? insets.left : insets.right
            let bottom = -(Self.margin + insets.bottom)
            let trailing = -(Self.margin + trailingInset)
            if bottomConstraint.constant != bottom { bottomConstraint.constant = bottom }
            if trailingConstraint.constant != trailing { trailingConstraint.constant = trailing }
        }
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updatePlacement()
    }

    // MARK: - Appearance

    private func updateAppearance() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .habPrimary
        config.baseForegroundColor = .habOnPrimary
        config.cornerStyle = .capsule
        config.image = icon
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        config.title = title
        config.imagePadding = HABSpacing.sm
        let horizontal = title == nil ? 0 : HABSpacing.lg - HABSpacing.xs
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontal, bottom: 0, trailing: horizontal)
        let font = UIFont.habHeadline
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        configuration = config

        applyElevation()

        accessibilityLabel = action.label
        accessibilityTraits = .button
    }

    /// The capsule background lives in a subview, so the shadow goes on this view's layer.
    private func applyElevation() {
        habTheme.shadows.high.apply(to: layer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: bounds.height / 2
        ).cgPath
    }

    // MARK: - Actions

    @objc private func tapped() {
        action.action()
    }

    @objc private func themeDidChange() {
        updateAppearance()
    }
}
