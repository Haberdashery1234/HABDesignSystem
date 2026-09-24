//
//  HABAppleTheme.swift
//  HABUIKit
//
//  A theme built entirely on Apple's adaptive semantic colors.
//  Colors automatically shift between light and dark based on the
//  user's system appearance — no hardcoded values anywhere.
//
//  Use this when you want components that look at home on any
//  Apple platform without any visual opinion of your own.
//
//  Contrast: this theme deliberately mirrors Apple's system colors, and some
//  of those fall below WCAG AA as small text (e.g. systemBlue behind white
//  body text, systemGreen/systemOrange as text on white). Contrast improves
//  when the user turns on Increase Contrast. If your app must meet WCAG AA
//  regardless of device settings, use HABLightTheme / HABDarkTheme (checked by
//  HABThemeContrastTests) or your own theme.
//

#if canImport(UIKit)
import UIKit

public struct HABAppleTheme: HABTheme {
    public let name = "HABApple"

    public var colors: HABColorTokens { HABColorTokens() }
    public var typography: HABTypographyTokens { HABTypographyTokens() }

    public init() {}
}
#endif
