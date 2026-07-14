//
//  UIFontTests.swift
//  HABUIKitTests
//
//  Tests for UIFont+HAB extensions and HABTextStyle helpers.
//

import XCTest
import HABUIKit

final class UIFontTests: XCTestCase {
    // MARK: - Static font properties

    func testHabDisplay() {
        XCTAssertNotNil(UIFont.habDisplay)
    }
    
    func testHabLargeTitle() {
        XCTAssertNotNil(UIFont.habLargeTitle)
    }
    
    func testHabTitle1() {
        XCTAssertNotNil(UIFont.habTitle1)
    }
    
    func testHabTitle2() {
        XCTAssertNotNil(UIFont.habTitle2)
    }
    
    func testHabTitle3() {
        XCTAssertNotNil(UIFont.habTitle3)
    }
    
    func testHabHeadline() {
        XCTAssertNotNil(UIFont.habHeadline)
    }
    
    func testHabBody() {
        XCTAssertNotNil(UIFont.habBody)
    }
    
    func testHabCallout() {
        XCTAssertNotNil(UIFont.habCallout)
    }
    
    func testHabSubheadline() {
        XCTAssertNotNil(UIFont.habSubheadline)
    }
    
    func testHabFootnote() {
        XCTAssertNotNil(UIFont.habFootnote)
    }
    
    func testHabCaption1() {
        XCTAssertNotNil(UIFont.habCaption1)
    }
    
    func testHabCaption2() {
        XCTAssertNotNil(UIFont.habCaption2)
    }
    
    // MARK: - habStyle(for:)

    func testHabStyleForAllKeys() {
        for key in HABTypographyKey.allCases {
            let style = UIFont.habStyle(for: key)
            XCTAssertNotNil(style.font, "Font missing for key \(key)")
        }
    }

    // MARK: - HABTextStyle.paragraphStyle

    func testParagraphStyleWithPositiveLineHeight() {
        let style = HABTextStyle(size: 17, weight: .regular, textStyle: .body, lineHeight: 22)
        let para = style.paragraphStyle as? NSMutableParagraphStyle
        // With lineHeight > 0 a mutable style with min/max set is returned
        XCTAssertNotNil(para)
        XCTAssertEqual(para?.minimumLineHeight, 22)
        XCTAssertEqual(para?.maximumLineHeight, 22)
    }

    func testParagraphStyleWithZeroLineHeightReturnsDefault() {
        let style = HABTextStyle(size: 17, weight: .regular, textStyle: .body, lineHeight: 0)
        let para = style.paragraphStyle
        // With lineHeight == 0 the default paragraph style is returned
        XCTAssertEqual(para, NSParagraphStyle.default)
    }

    // MARK: - HABTextStyle.attributedString

    func testAttributedStringContainsFont() {
        let style = HABTextStyle(size: 17, weight: .regular, textStyle: .body)
        let attributed = style.attributedString("Hello")
        let font = attributed.attribute(.font, at: 0, effectiveRange: nil)
        XCTAssertNotNil(font)
    }

    func testAttributedStringWithLetterSpacingContainsKern() {
        let style = HABTextStyle(
            size: 17,
            weight: .regular,
            textStyle: .body,
            lineHeight: 0,
            letterSpacing: 0.5
        )
        let attributed = style.attributedString("Hello")
        let kern = attributed.attribute(.kern, at: 0, effectiveRange: nil)
        XCTAssertNotNil(kern)
    }

    func testAttributedStringWithZeroLetterSpacingOmitsKern() {
        let style = HABTextStyle(
            size: 17,
            weight: .regular,
            textStyle: .body,
            lineHeight: 0,
            letterSpacing: 0
        )
        let attributed = style.attributedString("Hello")
        let kern = attributed.attribute(.kern, at: 0, effectiveRange: nil)
        XCTAssertNil(kern)
    }

    func testAttributedStringPreservesText() {
        let style = HABTextStyle(size: 17, weight: .regular, textStyle: .body)
        let attributed = style.attributedString("Test string")
        XCTAssertEqual(attributed.string, "Test string")
    }
}
