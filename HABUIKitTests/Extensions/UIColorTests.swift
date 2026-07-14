//
//  UIColorTests.swift
//  HABUIKitTests
//
//  Tests for UIColor+HAB extensions.
//  Each property simply delegates to the active theme — we verify they all
//  resolve without crashing and return a non-nil color.
//

import XCTest
import HABUIKit

final class UIColorTests: XCTestCase {
    // MARK: - Brand

    func testHabPrimary() {
        XCTAssertNotNil(UIColor.habPrimary)
    }
    
    func testHabSecondary() {
        XCTAssertNotNil(UIColor.habSecondary)
    }
    
    func testHabAccent() {
        XCTAssertNotNil(UIColor.habAccent)
    }

    // MARK: - Backgrounds

    func testHabBackground() {
        XCTAssertNotNil(UIColor.habBackground)
    }
    
    func testHabBackgroundSecondary() {
        XCTAssertNotNil(UIColor.habBackgroundSecondary)
    }
    
    func testHabSurface() {
        XCTAssertNotNil(UIColor.habSurface)
    }
    
    func testHabSurfaceElevated() {
        XCTAssertNotNil(UIColor.habSurfaceElevated)
    }
    
    // MARK: - Foreground

    func testHabForeground() {
        XCTAssertNotNil(UIColor.habForeground)
    }
    
    func testHabForegroundSecondary() {
        XCTAssertNotNil(UIColor.habForegroundSecondary)
    }
    
    func testHabForegroundTertiary() {
        XCTAssertNotNil(UIColor.habForegroundTertiary)
    }
    
    func testHabForegroundDisabled() {
        XCTAssertNotNil(UIColor.habForegroundDisabled)
    }
    
    func testHabForegroundInverted() {
        XCTAssertNotNil(UIColor.habForegroundInverted)
    }

    // MARK: - On-Brand

    func testHabOnPrimary() {
        XCTAssertNotNil(UIColor.habOnPrimary)
    }
    
    func testHabOnSecondary() {
        XCTAssertNotNil(UIColor.habOnSecondary)
    }

    // MARK: - Semantic States

    func testHabDestructive() {
        XCTAssertNotNil(UIColor.habDestructive)
    }
    
    func testHabDestructiveSurface() {
        XCTAssertNotNil(UIColor.habDestructiveSurface)
    }
    
    func testHabSuccess() {
        XCTAssertNotNil(UIColor.habSuccess)
    }
    
    func testHabSuccessSurface() {
        XCTAssertNotNil(UIColor.habSuccessSurface)
    }
    
    func testHabWarning() {
        XCTAssertNotNil(UIColor.habWarning)
    }
    
    func testHabWarningSurface() {
        XCTAssertNotNil(UIColor.habWarningSurface)
    }
    
    func testHabInfo() {
        XCTAssertNotNil(UIColor.habInfo)
    }
    
    func testHabInfoSurface() {
        XCTAssertNotNil(UIColor.habInfoSurface)
    }

    // MARK: - UI Chrome

    func testHabBorder() {
        XCTAssertNotNil(UIColor.habBorder)
    }
    
    func testHabBorderSubtle() {
        XCTAssertNotNil(UIColor.habBorderSubtle)
    }
    
    func testHabOverlay() {
        XCTAssertNotNil(UIColor.habOverlay)
    }
}
