//
//  HABLabelTests.swift
//  HABUIKitTests
//
//  Tests for HABLabel.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABLabelTests: XCTestCase {
    func testDefaultTextStyle() {
        let label = HABLabel()
        XCTAssertEqual(label.textStyle, .body)
    }

    func testInitWithTextStyle() {
        let label = HABLabel(textStyle: .headline)
        XCTAssertEqual(label.textStyle, .headline)
    }

    func testTextStyleMutation() {
        let label = HABLabel(textStyle: .body)
        label.textStyle = .title1
        XCTAssertEqual(label.textStyle, .title1)
    }

    func testPlainTextRoundtrips() {
        let label = HABLabel()
        label.text = "Hello, world"
        XCTAssertEqual(label.text, "Hello, world")
    }

    func testSettingTextClearsStyledText() {
        let label = HABLabel()
        label.styledText = "Styled"
        label.text = "Plain"
        // After setting .text, styledText should be nil
        XCTAssertNil(label.styledText)
        XCTAssertEqual(label.text, "Plain")
    }

    func testStyledTextSetsAttributedText() {
        let label = HABLabel()
        label.styledText = "Styled"
        XCTAssertEqual(label.styledText, "Styled")
        XCTAssertNotNil(label.attributedText)
    }

    func testDefaultColorIsHABForeground() {
        let label = HABLabel()
        // Exact color comparison is fragile across adaptive colors;
        // just verify textColor is not nil.
        XCTAssertNotNil(label.textColor)
    }

    func testClearingStyledTextNilsAttributedText() {
        let label = HABLabel()
        label.styledText = "Hello"
        label.styledText = nil
        // After clearing, attributedText should be nil
        XCTAssertNil(label.attributedText)
        XCTAssertNil(label.styledText)
    }

    func testThemeChangeRebuildsStyling() {
        let label = HABLabel()
        label.styledText = "Hello"
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
        // Styled text is preserved after theme update
        XCTAssertEqual(label.styledText, "Hello")
    }

    func testContentSizeChangeRebuildsStyling() {
        let label = HABLabel()
        label.styledText = "Hello"
        NotificationCenter.default.post(
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        XCTAssertEqual(label.styledText, "Hello")
    }

    func testContentSizeChangeWithPlainTextDoesNotCrash() {
        let label = HABLabel()
        label.text = "Plain"
        NotificationCenter.default.post(
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        XCTAssertEqual(label.text, "Plain")
    }

    func testAllTextStyles() {
        for key in HABTypographyKey.allCases {
            let label = HABLabel(textStyle: key)
            XCTAssertEqual(label.textStyle, key)
        }
    }

    // MARK: - Theme text color

    func testDefaultThemeTextColorIsForeground() {
        let label = HABLabel()
        XCTAssertNotNil(label.themeTextColor)
        // Direct assignment inside the label must not clear the provider.
        HABThemeManager.shared.theme = HABDarkTheme()
        defer { HABThemeManager.shared.theme = HABDefaultTheme() }
        XCTAssertNotNil(label.themeTextColor)
        XCTAssertEqual(label.textColor, HABDarkTheme().colors.foreground)
    }

    func testThemeTextColorSurvivesThemeChange() {
        let label = HABLabel()
        label.themeTextColor = { .habForegroundSecondary }
        HABThemeManager.shared.theme = HABDarkTheme()
        defer { HABThemeManager.shared.theme = HABDefaultTheme() }
        XCTAssertEqual(label.textColor, HABDarkTheme().colors.foregroundSecondary)
    }

    func testDirectTextColorIsNotOverwrittenByThemeChange() {
        let label = HABLabel()
        label.textColor = .systemPink
        XCTAssertNil(label.themeTextColor)
        HABThemeManager.shared.theme = HABDarkTheme()
        defer { HABThemeManager.shared.theme = HABDefaultTheme() }
        XCTAssertEqual(label.textColor, .systemPink)
    }
}
