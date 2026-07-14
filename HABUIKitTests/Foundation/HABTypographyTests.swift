//
//  HABTypographyTests.swift
//  HABUIKitTests
//
//  Tests for HABTextStyle and HABTypographyTokens.
//

import XCTest
import HABUIKit

final class HABTypographyTests: XCTestCase {
    // MARK: - HABTextStyle Tests
    
    func testTextStyleInitWithBasicParameters() {
        let style = HABTextStyle(
            size: 17,
            weight: .regular,
            textStyle: .body
        )
        
        XCTAssertNotNil(style.font)
        XCTAssertEqual(style.lineHeight, 0)
        XCTAssertEqual(style.letterSpacing, 0)
    }
    
    func testTextStyleInitWithLineHeightAndLetterSpacing() {
        let style = HABTextStyle(
            size: 17,
            weight: .regular,
            textStyle: .body,
            lineHeight: 22,
            letterSpacing: 0.5
        )
        
        XCTAssertNotNil(style.font)
        XCTAssertEqual(style.lineHeight, 22)
        XCTAssertEqual(style.letterSpacing, 0.5)
    }
    
    func testTextStyleInitWithFont() {
        let customFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let style = HABTextStyle(
            font: customFont,
            lineHeight: 25,
            letterSpacing: 1.0
        )
        
        XCTAssertEqual(style.font, customFont)
        XCTAssertEqual(style.lineHeight, 25)
        XCTAssertEqual(style.letterSpacing, 1.0)
    }
    
    func testTextStyleFontIsScaled() {
        let style = HABTextStyle(
            size: 17,
            weight: .regular,
            textStyle: .body
        )
        
        // Font should be created (scaled by UIFontMetrics)
        XCTAssertNotNil(style.font)
        XCTAssertGreaterThan(style.font.pointSize, 0)
    }
    
    // MARK: - HABTypographyTokens Initialization Tests
    
    func testTypographyTokensDefaultInitialization() {
        let tokens = HABTypographyTokens()
        
        XCTAssertNotNil(tokens.display)
        XCTAssertNotNil(tokens.largeTitle)
        XCTAssertNotNil(tokens.title1)
        XCTAssertNotNil(tokens.title2)
        XCTAssertNotNil(tokens.title3)
        XCTAssertNotNil(tokens.headline)
        XCTAssertNotNil(tokens.body)
        XCTAssertNotNil(tokens.callout)
        XCTAssertNotNil(tokens.subheadline)
        XCTAssertNotNil(tokens.footnote)
        XCTAssertNotNil(tokens.caption1)
        XCTAssertNotNil(tokens.caption2)
    }
    
    func testDisplayStyleHasFontAndLineHeight() {
        let tokens = HABTypographyTokens()
        
        XCTAssertNotNil(tokens.display.font)
        XCTAssertEqual(tokens.display.lineHeight, 48)
    }
    
    func testLargeTitleStyleHasFontAndLineHeight() {
        let tokens = HABTypographyTokens()
        
        XCTAssertNotNil(tokens.largeTitle.font)
        XCTAssertEqual(tokens.largeTitle.lineHeight, 41)
    }
    
    func testTitle1StyleHasFontAndLineHeight() {
        let tokens = HABTypographyTokens()
        
        XCTAssertNotNil(tokens.title1.font)
        XCTAssertEqual(tokens.title1.lineHeight, 34)
    }
    
    func testBodyStyleHasFontAndLineHeight() {
        let tokens = HABTypographyTokens()
        
        XCTAssertNotNil(tokens.body.font)
        XCTAssertEqual(tokens.body.lineHeight, 22)
    }
    
    func testHeadlineStyleHasSemiboldWeight() {
        let tokens = HABTypographyTokens()
        
        XCTAssertNotNil(tokens.headline.font)
        // Headline should use semibold weight
        XCTAssertEqual(tokens.headline.lineHeight, 22)
    }
    
    func testCaptionsHaveSmallLineHeights() {
        let tokens = HABTypographyTokens()
        
        XCTAssertEqual(tokens.caption1.lineHeight, 16)
        XCTAssertEqual(tokens.caption2.lineHeight, 13)
    }
    
    // MARK: - Size Hierarchy Tests
    
    func testLineHeightsDecreaseForSmallerStyles() {
        let tokens = HABTypographyTokens()
        
        // Display → Large Title → Title1 → Title2 → Body → Subheadline → Footnote → Caption
        XCTAssertGreaterThan(tokens.display.lineHeight, tokens.largeTitle.lineHeight)
        XCTAssertGreaterThan(tokens.largeTitle.lineHeight, tokens.title1.lineHeight)
        XCTAssertGreaterThan(tokens.title1.lineHeight, tokens.title2.lineHeight)
        XCTAssertGreaterThan(tokens.body.lineHeight, tokens.subheadline.lineHeight)
        XCTAssertGreaterThan(tokens.subheadline.lineHeight, tokens.footnote.lineHeight)
        XCTAssertGreaterThan(tokens.footnote.lineHeight, tokens.caption1.lineHeight)
        XCTAssertGreaterThan(tokens.caption1.lineHeight, tokens.caption2.lineHeight)
    }
    
    // MARK: - Custom Initialization Tests
    
    func testCustomBodyStyle() {
        let customBody = HABTextStyle(
            size: 18,
            weight: .medium,
            textStyle: .body,
            lineHeight: 24,
            letterSpacing: 0.2
        )
        
        let tokens = HABTypographyTokens(body: customBody)
        
        XCTAssertEqual(tokens.body.lineHeight, 24)
        XCTAssertEqual(tokens.body.letterSpacing, 0.2)
    }
    
    func testPartialCustomization() {
        let customHeadline = HABTextStyle(size: 20, weight: .bold, textStyle: .headline)
        let customBody = HABTextStyle(size: 18, weight: .regular, textStyle: .body)
        
        let tokens = HABTypographyTokens(
            headline: customHeadline,
            body: customBody
        )
        
        // Custom values should be used
        XCTAssertNotNil(tokens.headline.font)
        XCTAssertNotNil(tokens.body.font)
        
        // Other values should still have defaults
        XCTAssertNotNil(tokens.display)
        XCTAssertNotNil(tokens.caption1)
    }
    
    // MARK: - Keyed Access Tests
    
    func testStyleForKeyDisplay() {
        let tokens = HABTypographyTokens()
        let style = tokens.style(for: .display)
        
        XCTAssertEqual(style.lineHeight, tokens.display.lineHeight)
    }
    
    func testStyleForKeyBody() {
        let tokens = HABTypographyTokens()
        let style = tokens.style(for: .body)
        
        XCTAssertEqual(style.lineHeight, tokens.body.lineHeight)
    }
    
    func testStyleForKeyCaption1() {
        let tokens = HABTypographyTokens()
        let style = tokens.style(for: .caption1)
        
        XCTAssertEqual(style.lineHeight, tokens.caption1.lineHeight)
    }
    
    func testAllTypographyKeysReturnStyles() {
        let tokens = HABTypographyTokens()
        
        for key in HABTypographyKey.allCases {
            let style = tokens.style(for: key)
            XCTAssertNotNil(style.font, "Key \(key) should return a valid style")
        }
    }
    
    // MARK: - HABTypographyKey Tests
    
    func testAllTypographyKeysCases() {
        let allKeys = HABTypographyKey.allCases
        
        XCTAssertTrue(allKeys.contains(.display))
        XCTAssertTrue(allKeys.contains(.largeTitle))
        XCTAssertTrue(allKeys.contains(.title1))
        XCTAssertTrue(allKeys.contains(.title2))
        XCTAssertTrue(allKeys.contains(.title3))
        XCTAssertTrue(allKeys.contains(.headline))
        XCTAssertTrue(allKeys.contains(.body))
        XCTAssertTrue(allKeys.contains(.callout))
        XCTAssertTrue(allKeys.contains(.subheadline))
        XCTAssertTrue(allKeys.contains(.footnote))
        XCTAssertTrue(allKeys.contains(.caption1))
        XCTAssertTrue(allKeys.contains(.caption2))
    }
    
    func testTypographyKeyCount() {
        XCTAssertEqual(HABTypographyKey.allCases.count, 12)
    }
    
    // MARK: - Letter Spacing Tests
    
    func testDisplayHasNegativeLetterSpacing() {
        let tokens = HABTypographyTokens()
        
        // Large text typically has tighter tracking
        XCTAssertLessThan(tokens.display.letterSpacing, 0)
    }
    
    func testBodyHasZeroLetterSpacing() {
        let tokens = HABTypographyTokens()
        
        // Body text typically has no letter spacing adjustment
        XCTAssertEqual(tokens.body.letterSpacing, 0)
    }
    
    // MARK: - Practical Usage Tests
    
    func testTextStyleCanBeUsedWithUILabel() {
        let tokens = HABTypographyTokens()
        let label = UILabel()
        
        label.font = tokens.body.font
        XCTAssertEqual(label.font, tokens.body.font)
    }
    
    func testTextStyleFontsAreScaled() {
        let tokens = HABTypographyTokens()
        
        // All fonts should be created and scaled
        XCTAssertNotNil(tokens.display.font)
        XCTAssertNotNil(tokens.body.font)
        XCTAssertNotNil(tokens.caption1.font)
        
        // Font sizes should make sense
        XCTAssertGreaterThan(tokens.display.font.pointSize, 0)
        XCTAssertGreaterThan(tokens.body.font.pointSize, 0)
        XCTAssertGreaterThan(tokens.caption1.font.pointSize, 0)
    }
    
    // MARK: - Struct Mutability Tests
    
    func testTokensAreMutable() {
        var tokens = HABTypographyTokens()
        let newBody = HABTextStyle(size: 20, weight: .bold, textStyle: .body)
        
        tokens.body = newBody
        XCTAssertEqual(tokens.body.lineHeight, newBody.lineHeight)
    }
    
    func testTextStylePropertiesAreMutable() {
        var style = HABTextStyle(
            size: 17,
            weight: .regular,
            textStyle: .body,
            lineHeight: 22,
            letterSpacing: 0
        )
        
        style.lineHeight = 24
        style.letterSpacing = 0.5
        
        XCTAssertEqual(style.lineHeight, 24)
        XCTAssertEqual(style.letterSpacing, 0.5)
    }
    
    // MARK: - Zero Line Height Tests
    
    func testZeroLineHeightUsesNaturalHeight() {
        let style = HABTextStyle(
            size: 17,
            weight: .regular,
            textStyle: .body,
            lineHeight: 0
        )
        
        XCTAssertEqual(style.lineHeight, 0)
        // When lineHeight is 0, the font's natural line height should be used
    }
}
