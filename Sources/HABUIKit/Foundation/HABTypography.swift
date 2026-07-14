//
//  HABTypography.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

// MARK: - HABTextStyle

/// A single semantic text style, combining a Dynamic Type-scaled font
/// with line height and letter spacing values for full typographic fidelity.
///
/// Use `font` alone when assigning to `UILabel.font`. Use `lineHeight`
/// and `letterSpacing` when building `NSAttributedString`s for precise control.
public struct HABTextStyle {
    /// The Dynamic Type-scaled font. Automatically grows or shrinks
    /// with the user's text size preference in Settings.
    public var font: UIFont

    /// Desired total line height in points. Applied via `NSParagraphStyle.minimumLineHeight`
    /// and `NSParagraphStyle.maximumLineHeight` when building attributed strings.
    /// A value of `0` uses the font's natural line height.
    public var lineHeight: CGFloat

    /// Letter spacing (tracking) in points. Applied via `NSAttributedString`'s `.kern` attribute.
    /// A value of `0` applies no adjustment.
    public var letterSpacing: CGFloat

    /// Creates a text style with a Dynamic Type-scaled font.
    ///
    /// - Parameters:
    ///   - size: Base font size at the default accessibility text size.
    ///   - weight: Font weight.
    ///   - textStyle: The `UIFont.TextStyle` used to determine the Dynamic Type scaling curve.
    ///   - lineHeight: Desired total line height. Pass `0` to use the font's natural line height.
    ///   - letterSpacing: Tracking in points. Pass `0` for no adjustment.
    public init(
        size: CGFloat,
        weight: UIFont.Weight,
        textStyle: UIFont.TextStyle,
        lineHeight: CGFloat = 0,
        letterSpacing: CGFloat = 0
    ) {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        self.font          = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
        self.lineHeight    = lineHeight
        self.letterSpacing = letterSpacing
    }

    /// Creates a text style with a pre-built font. Use this when supplying
    /// a custom font family from a theme.
    ///
    /// The font is expected to already be scaled via `UIFontMetrics` if
    /// Dynamic Type support is desired.
    public init(font: UIFont, lineHeight: CGFloat = 0, letterSpacing: CGFloat = 0) {
        self.font          = font
        self.lineHeight    = lineHeight
        self.letterSpacing = letterSpacing
    }
}

// MARK: - HABTypographyKey

/// An identifier for each named text style in the HABUIKit type scale.
/// Used with `UIFont.habStyle(for:)` to retrieve the full `HABTextStyle`.
public enum HABTypographyKey: CaseIterable {
    case display
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption1
    case caption2
}

// MARK: - HABTypographyTokens

/// The complete set of semantic typography tokens for HABUIKit.
///
/// Themes provide values by creating an `HABTypographyTokens` instance and
/// overriding any styles they need. All styles have Dynamic Type-aware defaults
/// using SF Pro that work out of the box with no theme configured.
///
/// To use a custom font family, build your fonts via `UIFontMetrics` and pass
/// them using `HABTextStyle(font:lineHeight:letterSpacing:)`:
///
/// ```swift
/// var typography: HABTypographyTokens {
///     var tokens = HABTypographyTokens()
///     let base = UIFont(name: "MyFont-Regular", size: 17)!
///     tokens.body = HABTextStyle(
///         font: UIFontMetrics(forTextStyle: .body).scaledFont(for: base),
///         lineHeight: 22
///     )
///     return tokens
/// }
/// ```
public struct HABTypographyTokens {
    // MARK: Display & Titles

    /// Extra-large hero text. 40pt regular, 48pt line height.
    public var display: HABTextStyle

    /// Large title. 34pt regular, 41pt line height. Matches `UIFont.TextStyle.largeTitle`.
    public var largeTitle: HABTextStyle

    /// Title level 1. 28pt regular, 34pt line height.
    public var title1: HABTextStyle

    /// Title level 2. 22pt regular, 28pt line height.
    public var title2: HABTextStyle

    /// Title level 3. 20pt regular, 25pt line height.
    public var title3: HABTextStyle

    // MARK: Body

    /// Headline. 17pt semibold, 22pt line height. Used for emphasized body-level text.
    public var headline: HABTextStyle

    /// Body. 17pt regular, 22pt line height. The default reading size.
    public var body: HABTextStyle

    /// Callout. 16pt regular, 21pt line height.
    public var callout: HABTextStyle

    /// Subheadline. 15pt regular, 20pt line height.
    public var subheadline: HABTextStyle

    // MARK: Small

    /// Footnote. 13pt regular, 18pt line height.
    public var footnote: HABTextStyle

    /// Caption level 1. 12pt regular, 16pt line height.
    public var caption1: HABTextStyle

    /// Caption level 2. 11pt regular, 13pt line height.
    public var caption2: HABTextStyle

    // MARK: - Init

    /// Creates a typography token set. All parameters have Dynamic Type-aware
    /// defaults so only the styles you want to override need to be specified.
    public init(
        display: HABTextStyle = HABTextStyle(size: 40, weight: .regular, textStyle: .largeTitle, lineHeight: 48, letterSpacing: -0.5),
        largeTitle: HABTextStyle = HABTextStyle(size: 34, weight: .regular, textStyle: .largeTitle, lineHeight: 41, letterSpacing: -0.4),
        title1: HABTextStyle = HABTextStyle(size: 28, weight: .regular, textStyle: .title1, lineHeight: 34, letterSpacing: -0.3),
        title2: HABTextStyle = HABTextStyle(size: 22, weight: .regular, textStyle: .title2, lineHeight: 28, letterSpacing: 0),
        title3: HABTextStyle = HABTextStyle(size: 20, weight: .regular, textStyle: .title3, lineHeight: 25, letterSpacing: 0),
        headline: HABTextStyle = HABTextStyle(size: 17, weight: .semibold, textStyle: .headline, lineHeight: 22, letterSpacing: 0),
        body: HABTextStyle = HABTextStyle(size: 17, weight: .regular, textStyle: .body, lineHeight: 22, letterSpacing: 0),
        callout: HABTextStyle = HABTextStyle(size: 16, weight: .regular, textStyle: .callout, lineHeight: 21, letterSpacing: 0),
        subheadline: HABTextStyle = HABTextStyle(size: 15, weight: .regular, textStyle: .subheadline, lineHeight: 20, letterSpacing: 0),
        footnote: HABTextStyle = HABTextStyle(size: 13, weight: .regular, textStyle: .footnote, lineHeight: 18, letterSpacing: 0),
        caption1: HABTextStyle = HABTextStyle(size: 12, weight: .regular, textStyle: .caption1, lineHeight: 16, letterSpacing: 0),
        caption2: HABTextStyle = HABTextStyle(size: 11, weight: .regular, textStyle: .caption2, lineHeight: 13, letterSpacing: 0)
    ) {
        self.display = display
        self.largeTitle = largeTitle
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption1 = caption1
        self.caption2 = caption2
    }

    // MARK: - Keyed Access

    /// Returns the `HABTextStyle` for the given key.
    /// Used internally by `UIFont.habStyle(for:)`.
    public func style(for key: HABTypographyKey) -> HABTextStyle {
        switch key {
            case .display: return display
            case .largeTitle: return largeTitle
            case .title1: return title1
            case .title2: return title2
            case .title3: return title3
            case .headline: return headline
            case .body: return body
            case .callout: return callout
            case .subheadline: return subheadline
            case .footnote: return footnote
            case .caption1: return caption1
            case .caption2: return caption2
        }
    }
}
