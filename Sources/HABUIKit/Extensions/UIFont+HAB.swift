//
//  UIFont+HAB.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public extension UIFont {
    // MARK: - Full Style Access

    /// Returns the full `HABTextStyle` for the given key, including
    /// line height and letter spacing values for attributed string work.
    ///
    /// ```swift
    /// let style = UIFont.habStyle(for: .body)
    /// let attributes: [NSAttributedString.Key: Any] = [
    ///     .font:           style.font,
    ///     .kern:           style.letterSpacing,
    ///     .paragraphStyle: style.paragraphStyle
    /// ]
    /// ```
    static func habStyle(for key: HABTypographyKey) -> HABTextStyle {
        HABThemeManager.shared.theme.typography.style(for: key)
    }

    // MARK: - Convenience Font Access

    /// Display font. 40pt regular, scales with `.largeTitle` Dynamic Type curve.
    static var habDisplay: UIFont { HABThemeManager.shared.theme.typography.display.font }

    /// Large title font. 34pt regular, scales with `.largeTitle` Dynamic Type curve.
    static var habLargeTitle: UIFont { HABThemeManager.shared.theme.typography.largeTitle.font }

    /// Title 1 font. 28pt regular.
    static var habTitle1: UIFont { HABThemeManager.shared.theme.typography.title1.font }

    /// Title 2 font. 22pt regular.
    static var habTitle2: UIFont { HABThemeManager.shared.theme.typography.title2.font }

    /// Title 3 font. 20pt regular.
    static var habTitle3: UIFont { HABThemeManager.shared.theme.typography.title3.font }

    /// Headline font. 17pt semibold.
    static var habHeadline: UIFont { HABThemeManager.shared.theme.typography.headline.font }

    /// Body font. 17pt regular.
    static var habBody: UIFont { HABThemeManager.shared.theme.typography.body.font }

    /// Callout font. 16pt regular.
    static var habCallout: UIFont { HABThemeManager.shared.theme.typography.callout.font }

    /// Subheadline font. 15pt regular.
    static var habSubheadline: UIFont { HABThemeManager.shared.theme.typography.subheadline.font }

    /// Footnote font. 13pt regular.
    static var habFootnote: UIFont { HABThemeManager.shared.theme.typography.footnote.font }

    /// Caption 1 font. 12pt regular.
    static var habCaption1: UIFont { HABThemeManager.shared.theme.typography.caption1.font }

    /// Caption 2 font. 11pt regular.
    static var habCaption2: UIFont { HABThemeManager.shared.theme.typography.caption2.font }
}

// MARK: - HABTextStyle + NSParagraphStyle

public extension HABTextStyle {
    /// An `NSParagraphStyle` configured with this style's line height.
    /// Use this when building attributed strings to apply correct vertical rhythm.
    ///
    /// Returns `NSParagraphStyle.default` when `lineHeight` is `0`.
    var paragraphStyle: NSParagraphStyle {
        guard lineHeight > 0 else { return .default }
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
        return style
    }

    /// Builds an `NSAttributedString` applying this style's font,
    /// letter spacing, and line height to the given string.
    ///
    /// ```swift
    /// let style = UIFont.habStyle(for: .body)
    /// label.attributedText = style.attributedString("Hello, world")
    /// ```
    func attributedString(_ string: String) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        if letterSpacing != 0 {
            attributes[.kern] = letterSpacing
        }
        return NSAttributedString(string: string, attributes: attributes)
    }
}
