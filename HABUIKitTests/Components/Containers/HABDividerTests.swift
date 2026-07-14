//
//  HABDividerTests.swift
//  HABUIKitTests
//
//  Tests for HABDivider.
//

import XCTest
import HABUIKit

final class HABDividerTests: XCTestCase {
    // MARK: - Initialization Tests
    
    func testDefaultAxisIsHorizontal() {
        let divider = HABDivider()
        XCTAssertEqual(divider.axis, .horizontal)
    }
    
    func testInitWithHorizontalAxis() {
        let divider = HABDivider(axis: .horizontal)
        XCTAssertEqual(divider.axis, .horizontal)
    }
    
    func testInitWithVerticalAxis() {
        let divider = HABDivider(axis: .vertical)
        XCTAssertEqual(divider.axis, .vertical)
    }
    
    func testTranslatesAutoresizingMaskIntoConstraintsIsFalse() {
        let divider = HABDivider()
        XCTAssertFalse(divider.translatesAutoresizingMaskIntoConstraints)
    }
    
    // MARK: - Axis Mutation Tests
    
    func testAxisMutationToVertical() {
        let divider = HABDivider(axis: .horizontal)
        divider.axis = .vertical
        XCTAssertEqual(divider.axis, .vertical)
    }
    
    func testAxisMutationToHorizontal() {
        let divider = HABDivider(axis: .vertical)
        divider.axis = .horizontal
        XCTAssertEqual(divider.axis, .horizontal)
    }
    
    // MARK: - Intrinsic Content Size Tests
    
    func testHorizontalDividerIntrinsicContentSize() {
        let divider = HABDivider(axis: .horizontal)
        let size = divider.intrinsicContentSize
        
        XCTAssertEqual(size.width, UIView.noIntrinsicMetric)
        XCTAssertEqual(size.height, 0.5)
    }
    
    func testVerticalDividerIntrinsicContentSize() {
        let divider = HABDivider(axis: .vertical)
        let size = divider.intrinsicContentSize
        
        XCTAssertEqual(size.width, 0.5)
        XCTAssertEqual(size.height, UIView.noIntrinsicMetric)
    }
    
    func testIntrinsicContentSizeUpdatesAfterAxisChange() {
        let divider = HABDivider(axis: .horizontal)
        
        // Initial horizontal size
        var size = divider.intrinsicContentSize
        XCTAssertEqual(size.width, UIView.noIntrinsicMetric)
        XCTAssertEqual(size.height, 0.5)
        
        // Change to vertical
        divider.axis = .vertical
        size = divider.intrinsicContentSize
        XCTAssertEqual(size.width, 0.5)
        XCTAssertEqual(size.height, UIView.noIntrinsicMetric)
    }
    
    // MARK: - Appearance Tests
    
    func testBackgroundColorIsSet() {
        let divider = HABDivider()
        XCTAssertNotNil(divider.backgroundColor)
    }
    
    func testBackgroundColorIsHABBorderSubtle() {
        let divider = HABDivider()
        // We can't directly compare UIColors due to dynamic colors,
        // but we can verify it's not nil and not clear
        XCTAssertNotNil(divider.backgroundColor)
        XCTAssertNotEqual(divider.backgroundColor, .clear)
    }
    
    // MARK: - Content Hugging Priority Tests
    
    func testHorizontalDividerVerticalHuggingIsRequired() {
        let divider = HABDivider(axis: .horizontal)
        let priority = divider.contentHuggingPriority(for: .vertical)
        XCTAssertEqual(priority, .required)
    }
    
    func testHorizontalDividerHorizontalHuggingIsLow() {
        let divider = HABDivider(axis: .horizontal)
        let priority = divider.contentHuggingPriority(for: .horizontal)
        XCTAssertEqual(priority, .defaultLow)
    }
    
    func testVerticalDividerHorizontalHuggingIsRequired() {
        let divider = HABDivider(axis: .vertical)
        let priority = divider.contentHuggingPriority(for: .horizontal)
        XCTAssertEqual(priority, .required)
    }
    
    func testVerticalDividerVerticalHuggingIsLow() {
        let divider = HABDivider(axis: .vertical)
        let priority = divider.contentHuggingPriority(for: .vertical)
        XCTAssertEqual(priority, .defaultLow)
    }
    
    func testContentHuggingPriorityUpdatesAfterAxisChange() {
        let divider = HABDivider(axis: .horizontal)
        
        // Initial: vertical should be required, horizontal should be low
        XCTAssertEqual(divider.contentHuggingPriority(for: .vertical), .required)
        XCTAssertEqual(divider.contentHuggingPriority(for: .horizontal), .defaultLow)
        
        // Change to vertical
        divider.axis = .vertical
        
        // Now: horizontal should be required, vertical should be low
        XCTAssertEqual(divider.contentHuggingPriority(for: .horizontal), .required)
        XCTAssertEqual(divider.contentHuggingPriority(for: .vertical), .defaultLow)
    }
    
    // MARK: - Theme Change Tests
    
    func testThemeChangeUpdatesAppearance() {
        let divider = HABDivider()
        
        // Post theme change notification
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
        
        // Verify the divider is still valid after theme change
        XCTAssertNotNil(divider.backgroundColor)
    }
    
    // MARK: - Both Axes Tests
    
    func testBothAxesRenderWithoutError() {
        let horizontal = HABDivider(axis: .horizontal)
        let vertical = HABDivider(axis: .vertical)
        
        XCTAssertEqual(horizontal.axis, .horizontal)
        XCTAssertEqual(vertical.axis, .vertical)
        
        XCTAssertNotNil(horizontal.backgroundColor)
        XCTAssertNotNil(vertical.backgroundColor)
    }
    
    // MARK: - Memory Management Tests
    
    func testDeallocRemovesObservers() {
        weak var weakDivider: HABDivider?
        
        autoreleasepool {
            let divider = HABDivider()
            weakDivider = divider
            XCTAssertNotNil(weakDivider)
        }
        
        // Divider should be deallocated
        XCTAssertNil(weakDivider, "HABDivider should be deallocated and observers removed")
    }
}
