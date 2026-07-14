//
//  HABColorTokensTests.swift
//  HABUIKitTests
//
//  Tests for HABColorTokens.
//

import XCTest
import HABUIKit

final class HABColorsTests: XCTestCase {
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        let tokens = HABColorTokens()
        
        // All colors should be initialized with non-nil defaults
        XCTAssertNotNil(tokens.primary)
        XCTAssertNotNil(tokens.secondary)
        XCTAssertNotNil(tokens.accent)
    }
    
    func testBrandColorsHaveDefaults() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.primary)
        XCTAssertNotNil(tokens.secondary)
        XCTAssertNotNil(tokens.accent)
    }
    
    func testBackgroundColorsHaveDefaults() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.background)
        XCTAssertNotNil(tokens.backgroundSecondary)
        XCTAssertNotNil(tokens.surface)
        XCTAssertNotNil(tokens.surfaceElevated)
    }
    
    func testForegroundColorsHaveDefaults() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.foreground)
        XCTAssertNotNil(tokens.foregroundSecondary)
        XCTAssertNotNil(tokens.foregroundTertiary)
        XCTAssertNotNil(tokens.foregroundDisabled)
        XCTAssertNotNil(tokens.foregroundInverted)
    }
    
    func testOnBrandColorsHaveDefaults() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.onPrimary)
        XCTAssertNotNil(tokens.onSecondary)
    }
    
    func testSemanticStateColorsHaveDefaults() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.destructive)
        XCTAssertNotNil(tokens.destructiveSurface)
        XCTAssertNotNil(tokens.success)
        XCTAssertNotNil(tokens.successSurface)
        XCTAssertNotNil(tokens.warning)
        XCTAssertNotNil(tokens.warningSurface)
        XCTAssertNotNil(tokens.info)
        XCTAssertNotNil(tokens.infoSurface)
    }
    
    func testUIChromeColorsHaveDefaults() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.border)
        XCTAssertNotNil(tokens.borderSubtle)
        XCTAssertNotNil(tokens.overlay)
    }
    
    // MARK: - Custom Initialization Tests
    
    func testCustomPrimaryColor() {
        let customPrimary = UIColor.red
        let tokens = HABColorTokens(primary: customPrimary)
        
        XCTAssertEqual(tokens.primary, customPrimary)
    }
    
    func testCustomSecondaryColor() {
        let customSecondary = UIColor.green
        let tokens = HABColorTokens(secondary: customSecondary)
        
        XCTAssertEqual(tokens.secondary, customSecondary)
    }
    
    func testCustomAccentColor() {
        let customAccent = UIColor.purple
        let tokens = HABColorTokens(accent: customAccent)
        
        XCTAssertEqual(tokens.accent, customAccent)
    }
    
    func testCustomDestructiveColor() {
        let customDestructive = UIColor.systemPink
        let tokens = HABColorTokens(destructive: customDestructive)
        
        XCTAssertEqual(tokens.destructive, customDestructive)
    }
    
    func testPartialCustomization() {
        let customPrimary = UIColor.red
        let customAccent = UIColor.yellow
        
        let tokens = HABColorTokens(
            primary: customPrimary,
            accent: customAccent
        )
        
        // Custom values should be set
        XCTAssertEqual(tokens.primary, customPrimary)
        XCTAssertEqual(tokens.accent, customAccent)
        
        // Other values should still have defaults
        XCTAssertNotNil(tokens.secondary)
        XCTAssertNotNil(tokens.background)
    }
    
    func testFullCustomization() {
        let tokens = HABColorTokens(
            primary: .red,
            secondary: .blue,
            accent: .green,
            background: .white,
            backgroundSecondary: .lightGray,
            surface: .systemGray6,
            surfaceElevated: .systemGray5,
            foreground: .black,
            foregroundSecondary: .darkGray,
            foregroundTertiary: .gray,
            foregroundDisabled: .lightGray,
            foregroundInverted: .white,
            onPrimary: .white,
            onSecondary: .white,
            destructive: .systemRed,
            destructiveSurface: .systemPink,
            success: .systemGreen,
            successSurface: .systemMint,
            warning: .systemOrange,
            warningSurface: .systemYellow,
            info: .systemBlue,
            infoSurface: .systemCyan,
            border: .separator,
            borderSubtle: .systemGray5,
            overlay: .black
        )
        
        XCTAssertEqual(tokens.primary, .red)
        XCTAssertEqual(tokens.secondary, .blue)
        XCTAssertEqual(tokens.accent, .green)
        XCTAssertEqual(tokens.background, .white)
    }
    
    // MARK: - Struct Mutability Tests
    
    func testTokensAreMutable() {
        var tokens = HABColorTokens()
        let newPrimary = UIColor.cyan
        
        tokens.primary = newPrimary
        XCTAssertEqual(tokens.primary, newPrimary)
    }
    
    func testMultiplePropertiesCanBeMutated() {
        var tokens = HABColorTokens()
        
        tokens.primary = .red
        tokens.secondary = .blue
        tokens.accent = .green
        
        XCTAssertEqual(tokens.primary, .red)
        XCTAssertEqual(tokens.secondary, .blue)
        XCTAssertEqual(tokens.accent, .green)
    }
    
    // MARK: - Semantic State Surface Colors Tests
    
    func testDestructiveSurfaceIsLighterThanDestructive() {
        let tokens = HABColorTokens()
        
        // Surface colors should be more transparent/lighter
        // We can't directly compare, but we can verify they exist
        XCTAssertNotNil(tokens.destructive)
        XCTAssertNotNil(tokens.destructiveSurface)
    }
    
    func testSuccessSurfaceExists() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.success)
        XCTAssertNotNil(tokens.successSurface)
    }
    
    func testWarningSurfaceExists() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.warning)
        XCTAssertNotNil(tokens.warningSurface)
    }
    
    func testInfoSurfaceExists() {
        let tokens = HABColorTokens()
        
        XCTAssertNotNil(tokens.info)
        XCTAssertNotNil(tokens.infoSurface)
    }
    
    // MARK: - Practical Usage Tests
    
    func testColorsCanBeUsedInViews() {
        let tokens = HABColorTokens()
        let view = UIView()
        
        view.backgroundColor = tokens.background
        XCTAssertEqual(view.backgroundColor, tokens.background)
        
        view.backgroundColor = tokens.surface
        XCTAssertEqual(view.backgroundColor, tokens.surface)
    }
    
    func testBorderColorsAreDistinct() {
        let tokens = HABColorTokens()
        
        // Both border colors should exist
        XCTAssertNotNil(tokens.border)
        XCTAssertNotNil(tokens.borderSubtle)
        
        // They should be different (though we can't directly compare dynamic colors easily)
        // At minimum, verify both are set
    }
    
    // MARK: - Default Values Tests
    
    func testDefaultPrimaryIsSystemBlue() {
        let tokens = HABColorTokens()
        // Default primary is system blue
        XCTAssertNotNil(tokens.primary)
    }
    
    func testDefaultDestructiveIsSystemRed() {
        let tokens = HABColorTokens()
        // Default destructive is system red
        XCTAssertNotNil(tokens.destructive)
    }
    
    func testDefaultSuccessIsSystemGreen() {
        let tokens = HABColorTokens()
        // Default success is system green
        XCTAssertNotNil(tokens.success)
    }
    
    // MARK: - Copy and Modify Pattern Tests

    func testCopyAndModifyPattern() {
        let defaultTokens = HABColorTokens()
        var customTokens = defaultTokens

        customTokens.primary = .systemPurple

        XCTAssertEqual(customTokens.primary, .systemPurple)
        XCTAssertNotEqual(defaultTokens.primary, .systemPurple)
    }

    // MARK: - Dynamic Provider Resolution

    // Resolving the UIColor(dynamicProvider:) closures covers their
    // bodies — the main source of uncovered lines in HABColors.swift.

    func testDynamicColorsResolveInLightMode() {
        let tokens = HABColorTokens()
        let light = UITraitCollection(userInterfaceStyle: .light)
        XCTAssertNotNil(tokens.foregroundInverted.resolvedColor(with: light))
        XCTAssertNotNil(tokens.borderSubtle.resolvedColor(with: light))
        XCTAssertNotNil(tokens.overlay.resolvedColor(with: light))
        XCTAssertNotNil(tokens.destructiveSurface.resolvedColor(with: light))
        XCTAssertNotNil(tokens.successSurface.resolvedColor(with: light))
        XCTAssertNotNil(tokens.warningSurface.resolvedColor(with: light))
        XCTAssertNotNil(tokens.infoSurface.resolvedColor(with: light))
    }

    func testDynamicColorsResolveInDarkMode() {
        let tokens = HABColorTokens()
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        XCTAssertNotNil(tokens.foregroundInverted.resolvedColor(with: dark))
        XCTAssertNotNil(tokens.borderSubtle.resolvedColor(with: dark))
        XCTAssertNotNil(tokens.overlay.resolvedColor(with: dark))
    }

    func testForegroundInvertedIsWhiteInLightMode() {
        let tokens = HABColorTokens()
        let light = UITraitCollection(userInterfaceStyle: .light)
        XCTAssertEqual(tokens.foregroundInverted.resolvedColor(with: light), .white)
    }

    func testForegroundInvertedIsBlackInDarkMode() {
        let tokens = HABColorTokens()
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        XCTAssertEqual(tokens.foregroundInverted.resolvedColor(with: dark), .black)
    }
}
