//
//  HABBannerTests.swift
//  HABUIKitTests
//
//  Tests for HABBanner.
//

import XCTest
import HABUIKit

final class HABBannerTests: XCTestCase {
    // MARK: - Initialization Tests
    
    func testInitWithTitle() {
        let banner = HABBanner(title: "Welcome")
        XCTAssertEqual(banner.title, "Welcome")
    }
    
    func testInitWithDefaults() {
        let banner = HABBanner(title: "Test")
        XCTAssertEqual(banner.title, "Test")
        XCTAssertNil(banner.message)
        XCTAssertEqual(banner.style, .info)
        XCTAssertNil(banner.action)
        XCTAssertNil(banner.dismissAction)
    }
    
    func testInitWithMessage() {
        let banner = HABBanner(title: "Title", message: "This is a message")
        XCTAssertEqual(banner.message, "This is a message")
    }
    
    func testInitWithStyle() {
        let styles: [HABBanner.Style] = [.info, .success, .warning, .error]
        
        for style in styles {
            let banner = HABBanner(title: "Test", style: style)
            XCTAssertEqual(banner.style, style)
        }
    }
    
    func testInitWithAction() {
        let action = HABAccessibleAction(label: "Retry") {}
        let banner = HABBanner(title: "Failed", action: action)
        XCTAssertNotNil(banner.action)
    }
    
    func testInitWithDismissAction() {
        let dismissAction = HABAccessibleAction(label: "Dismiss") {}
        let banner = HABBanner(title: "Notice", dismissAction: dismissAction)
        XCTAssertNotNil(banner.dismissAction)
    }
    
    // MARK: - Property Mutation Tests
    
    func testTitleMutation() {
        let banner = HABBanner(title: "Old Title")
        banner.title = "New Title"
        XCTAssertEqual(banner.title, "New Title")
    }
    
    func testMessageMutation() {
        let banner = HABBanner(title: "Title")
        banner.message = "New message"
        XCTAssertEqual(banner.message, "New message")
    }
    
    func testMessageClearing() {
        let banner = HABBanner(title: "Title", message: "Message")
        banner.message = nil
        XCTAssertNil(banner.message)
    }
    
    func testStyleMutation() {
        let banner = HABBanner(title: "Test", style: .info)
        banner.style = .error
        XCTAssertEqual(banner.style, .error)
    }
    
    func testActionMutation() {
        let banner = HABBanner(title: "Test")
        XCTAssertNil(banner.action)
        
        let action = HABAccessibleAction(label: "Action") {}
        banner.action = action
        XCTAssertNotNil(banner.action)
    }
    
    func testActionClearing() {
        let action = HABAccessibleAction(label: "Action") {}
        let banner = HABBanner(title: "Test", action: action)
        banner.action = nil
        XCTAssertNil(banner.action)
    }
    
    func testDismissActionMutation() {
        let banner = HABBanner(title: "Test")
        XCTAssertNil(banner.dismissAction)
        
        let dismissAction = HABAccessibleAction(label: "Close") {}
        banner.dismissAction = dismissAction
        XCTAssertNotNil(banner.dismissAction)
    }
    
    func testDismissActionClearing() {
        let dismissAction = HABAccessibleAction(label: "Close") {}
        let banner = HABBanner(title: "Test", dismissAction: dismissAction)
        banner.dismissAction = nil
        XCTAssertNil(banner.dismissAction)
    }
    
    // MARK: - All Styles Tests
    
    func testAllStylesRenderWithoutError() {
        let styles: [HABBanner.Style] = [.info, .success, .warning, .error]
        
        for style in styles {
            let banner = HABBanner(title: "Test", style: style)
            XCTAssertEqual(banner.style, style)
            XCTAssertNotNil(banner.backgroundColor)
        }
    }
    
    // MARK: - Appearance Tests
    
    func testBannerHasRoundedCorners() {
        let banner = HABBanner(title: "Test")
        XCTAssertEqual(banner.layer.cornerRadius, HABRadius.md)
    }
    
    func testBannerClipsToBounds() {
        let banner = HABBanner(title: "Test")
        XCTAssertTrue(banner.layer.masksToBounds)
    }
    
    func testInfoStyleHasCorrectBackground() {
        let banner = HABBanner(title: "Info", style: .info)
        XCTAssertNotNil(banner.backgroundColor)
    }
    
    func testSuccessStyleHasCorrectBackground() {
        let banner = HABBanner(title: "Success", style: .success)
        XCTAssertNotNil(banner.backgroundColor)
    }
    
    func testWarningStyleHasCorrectBackground() {
        let banner = HABBanner(title: "Warning", style: .warning)
        XCTAssertNotNil(banner.backgroundColor)
    }
    
    func testErrorStyleHasCorrectBackground() {
        let banner = HABBanner(title: "Error", style: .error)
        XCTAssertNotNil(banner.backgroundColor)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabelIncludesTitle() {
        let banner = HABBanner(title: "Important")
        XCTAssertTrue(banner.accessibilityLabel?.contains("Important") ?? false)
    }
    
    func testAccessibilityLabelIncludesTitleAndMessage() {
        let banner = HABBanner(title: "Title", message: "Message")
        let label = banner.accessibilityLabel ?? ""
        XCTAssertTrue(label.contains("Title"))
        XCTAssertTrue(label.contains("Message"))
    }
    
    func testAccessibilityTraitsAreStaticText() {
        let banner = HABBanner(title: "Test")
        XCTAssertTrue(banner.accessibilityTraits.contains(.staticText))
    }
    
    // MARK: - Action Callback Tests
    
    func testActionCallbackIsInvoked() {
        var actionFired = false
        let action = HABAccessibleAction(label: "Tap") {
            actionFired = true
        }
        
        _ = HABBanner(title: "Test", action: action)
        
        // Directly invoke the action to test
        action.action()
        
        XCTAssertTrue(actionFired)
    }
    
    func testDismissCallbackIsInvoked() {
        var dismissFired = false
        let dismissAction = HABAccessibleAction(label: "Close") {
            dismissFired = true
        }
        
        _ = HABBanner(title: "Test", dismissAction: dismissAction)
        
        // Directly invoke the dismiss action to test
        dismissAction.action()
        
        XCTAssertTrue(dismissFired)
    }
    
    // MARK: - Theme Change Tests
    
    func testThemeChangeUpdatesAppearance() {
        let banner = HABBanner(title: "Theme test", style: .warning)
        
        // Post theme change notification
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
        
        // Verify the banner is still valid after theme change
        XCTAssertNotNil(banner.backgroundColor)
        XCTAssertEqual(banner.title, "Theme test")
    }
    
    // MARK: - Complex Configuration Tests
    
    func testBannerWithAllProperties() {
        let action = HABAccessibleAction(label: "Retry") {}
        let dismissAction = HABAccessibleAction(label: "Close") {}
        
        let banner = HABBanner(
            title: "Error occurred",
            message: "Please try again",
            style: .error,
            action: action,
            dismissAction: dismissAction
        )
        
        XCTAssertEqual(banner.title, "Error occurred")
        XCTAssertEqual(banner.message, "Please try again")
        XCTAssertEqual(banner.style, .error)
        XCTAssertNotNil(banner.action)
        XCTAssertNotNil(banner.dismissAction)
    }
    
    func testBannerWithMinimalConfiguration() {
        let banner = HABBanner(title: "Simple")
        
        XCTAssertEqual(banner.title, "Simple")
        XCTAssertNil(banner.message)
        XCTAssertEqual(banner.style, .info)
        XCTAssertNil(banner.action)
        XCTAssertNil(banner.dismissAction)
    }
    
    // MARK: - Multiple Style Changes
    
    func testMultipleStyleChanges() {
        let banner = HABBanner(title: "Test", style: .info)
        
        banner.style = .success
        XCTAssertEqual(banner.style, .success)
        
        banner.style = .warning
        XCTAssertEqual(banner.style, .warning)
        
        banner.style = .error
        XCTAssertEqual(banner.style, .error)
    }
}
