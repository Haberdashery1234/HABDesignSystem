//
//  HABLabel.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

/// A UILabel subclass that stays in sync with the active HABUIKit theme and type scale.
///
/// ## Plain text
/// Set `text` directly. The font resolves from `textStyle` and scales automatically
/// with the user's Dynamic Type setting.
///
/// ```swift
/// let label = HABLabel(textStyle: .headline)
/// label.text = "Hello"
/// ```
///
/// ## Styled text
/// Use `styledText` when you need the full type scale token applied — font, line height,
/// and letter spacing. The style is rebuilt automatically whenever the theme or the
/// user's Dynamic Type setting changes.
///
/// ```swift
/// label.styledText = "Hello"
/// ```
///
/// ## Attributed text
/// Set `attributedText` directly for mixed-style content. This works identically
/// to UILabel — HABLabel does not interfere. Rebuilding on theme or Dynamic Type
/// changes is the caller's responsibility.
///
/// ```swift
/// label.attributedText = myCustomAttributedString
/// ```
public final class HABLabel: UILabel {
    // MARK: - Public

    /// The type scale token that drives the label's font.
    /// Changing this re-resolves the font (or styled text) from the active theme immediately.
    public var textStyle: HABTypographyKey = .body {
        didSet { handleStyleChange() }
    }

    /// Sets text with the full type scale token applied — font, line height, and
    /// letter spacing from the active theme. The style is rebuilt automatically
    /// when the theme or Dynamic Type setting changes.
    ///
    /// Set to `nil` or assign `text` directly to exit styled mode.
    public var styledText: String? {
        get { styledString }
        set {
            styledString = newValue
            applyAttributed()
        }
    }

    // MARK: - Overrides

    /// Setting `text` exits styled mode. The label returns to plain font rendering
    /// and Dynamic Type scaling via `adjustsFontForContentSizeCategory` resumes.
    public override var text: String? {
        get { super.text }
        set {
            styledString = nil
            super.text = newValue
        }
    }

    // MARK: - Private

    /// The plain string backing `styledText`. Retained so the attributed style
    /// can be rebuilt from the current theme and type scale on any change.
    private var styledString: String?

    // MARK: - Init

    public init(textStyle: HABTypographyKey = .body) {
        self.textStyle = textStyle
        super.init(frame: .zero)
        numberOfLines = 0
        textColor = .habForeground
        // Handles Dynamic Type automatically in plain-text mode.
        // No effect when styledText is set — changes are handled via the notification.
        adjustsFontForContentSizeCategory = true
        applyFont()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: HABThemeManager.themeDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    @objc private func themeDidChange() {
        textColor = .habForeground
        handleStyleChange()
    }

    @objc private func contentSizeDidChange() {
        // Plain-text mode is covered by adjustsFontForContentSizeCategory.
        // Styled mode must rebuild the attributed string with the newly scaled font.
        guard styledString != nil else { return }
        applyAttributed()
    }

    private func handleStyleChange() {
        if styledString != nil {
            applyAttributed()
        } else {
            applyFont()
        }
    }

    private func applyFont() {
        font = UIFont.habStyle(for: textStyle).font
    }

    private func applyAttributed() {
        guard let styledString else {
            attributedText = nil
            return
        }
        attributedText = UIFont.habStyle(for: textStyle).attributedString(styledString)
    }
}
