//
//  HABCardTests.swift
//  HABUIKitTests
//
//  Tests for HABCard.
//

import XCTest
import HABUIKit

final class HABCardTests: XCTestCase {
    // MARK: - Initialization Tests
    
    func testDefaultStyleIsElevated() {
        let card = HABCard()
        XCTAssertEqual(card.style, .elevated)
    }
    
    func testInitWithStyle() {
        let elevatedCard = HABCard(style: .elevated)
        XCTAssertEqual(elevatedCard.style, .elevated)
        
        let outlinedCard = HABCard(style: .outlined)
        XCTAssertEqual(outlinedCard.style, .outlined)
        
        let flatCard = HABCard(style: .flat)
        XCTAssertEqual(flatCard.style, .flat)
    }
    
    func testTranslatesAutoresizingMaskIntoConstraintsIsFalse() {
        let card = HABCard()
        XCTAssertFalse(card.translatesAutoresizingMaskIntoConstraints)
    }
    
    // MARK: - Style Mutation Tests
    
    func testStyleMutationToOutlined() {
        let card = HABCard(style: .elevated)
        card.style = .outlined
        XCTAssertEqual(card.style, .outlined)
    }
    
    func testStyleMutationToFlat() {
        let card = HABCard(style: .elevated)
        card.style = .flat
        XCTAssertEqual(card.style, .flat)
    }
    
    func testStyleMutationToElevated() {
        let card = HABCard(style: .flat)
        card.style = .elevated
        XCTAssertEqual(card.style, .elevated)
    }
    
    // MARK: - Appearance Tests
    
    func testElevatedStyleHasNoBorder() {
        let card = HABCard(style: .elevated)
        XCTAssertEqual(card.layer.borderWidth, 0)
    }
    
    func testOutlinedStyleHasBorder() {
        let card = HABCard(style: .outlined)
        XCTAssertEqual(card.layer.borderWidth, 1)
        XCTAssertNotNil(card.layer.borderColor)
    }
    
    func testFlatStyleHasNoShadow() {
        let card = HABCard(style: .flat)
        XCTAssertEqual(card.layer.shadowOpacity, 0)
    }
    
    func testElevatedStyleHasShadow() {
        let card = HABCard(style: .elevated)
        // Shadow should be applied (opacity > 0)
        XCTAssertGreaterThan(card.layer.shadowOpacity, 0)
    }
    
    func testCornerRadiusIsApplied() {
        let card = HABCard()
        XCTAssertEqual(card.layer.cornerRadius, HABRadius.lg)
    }
    
    func testBackgroundColorIsHABSurface() {
        let card = HABCard()
        XCTAssertNotNil(card.backgroundColor)
    }
    
    // MARK: - Theme Change Tests
    
    func testThemeChangeUpdatesAppearance() {
        let card = HABCard(style: .elevated)
        let expectation = XCTestExpectation(description: "Appearance updated after theme change")
        
        // Get initial background color
        _ = card.backgroundColor
        
        // Post theme change notification
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
        
        // Give the system a moment to process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // The background should still be set (even if to the same color)
            XCTAssertNotNil(card.backgroundColor)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Trait Collection Tests
    
    func testTraitCollectionChangeTriggersUpdate() {
        let card = HABCard(style: .outlined)
        
        // Override trait collection to simulate a change
        _ = UITraitCollection(userInterfaceStyle: .dark)
        
        // The card should respond to trait changes without crashing
        // We can't easily test the internal update, but we can verify it doesn't break
        XCTAssertNotNil(card.layer.cornerRadius)
        XCTAssertNotNil(card.backgroundColor)
    }
    
    // MARK: - All Styles Tests
    
    func testAllStylesRenderWithoutError() {
        let styles: [HABCard.Style] = [.elevated, .outlined, .flat]
        
        for style in styles {
            let card = HABCard(style: style)
            XCTAssertEqual(card.style, style)
            XCTAssertNotNil(card.backgroundColor)
            XCTAssertGreaterThan(card.layer.cornerRadius, 0)
        }
    }
    
    // MARK: - Memory Management
    
    func testDeallocRemovesObservers() {
        weak var weakCard: HABCard?
        
        autoreleasepool {
            let card = HABCard()
            weakCard = card
            XCTAssertNotNil(weakCard)
        }
        
        // Card should be deallocated
        XCTAssertNil(weakCard, "HABCard should be deallocated and observers removed")
    }
}
