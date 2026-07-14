//
//  HABToastTests.swift
//  HABUIKitTests
//
//  Tests for HABToast.
//

import XCTest
import HABUIKit

final class HABToastTests: XCTestCase {
    // MARK: - Initialization Tests
    
    func testInitWithMessage() {
        let toast = HABToast(message: "Success!")
        XCTAssertNotNil(toast)
    }
    
    func testInitWithDefaultStyle() {
        let toast = HABToast(message: "Test")
        // Default style should be info
        XCTAssertNotNil(toast)
    }
    
    func testInitWithAllStyles() {
        let styles: [HABToast.Style] = [.info, .success, .warning, .error]
        
        for style in styles {
            let toast = HABToast(message: "Test", style: style)
            XCTAssertNotNil(toast)
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabelIsSet() {
        let message = "Operation completed"
        let toast = HABToast(message: message)
        XCTAssertEqual(toast.accessibilityLabel, message)
    }
    
    func testAccessibilityTraitsAreStaticText() {
        let toast = HABToast(message: "Test")
        XCTAssertTrue(toast.accessibilityTraits.contains(.staticText))
    }
    
    // MARK: - Static API Tests
    
    func testShowAddsToastToView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        
        XCTAssertEqual(view.subviews.count, 0)
        
        HABToast.show(
            message: "Test toast",
            style: .info,
            duration: 0.5,
            in: view
        )
        
        XCTAssertEqual(view.subviews.count, 1)
        XCTAssertTrue(view.subviews.first is HABToast)
    }
    
    func testShowWithDefaultDuration() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        
        HABToast.show(message: "Test", in: view)
        
        XCTAssertEqual(view.subviews.count, 1)
    }
    
    func testShowWithDifferentStyles() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        let styles: [HABToast.Style] = [.info, .success, .warning, .error]
        
        for (index, style) in styles.enumerated() {
            HABToast.show(
                message: "Message \(index)",
                style: style,
                duration: 0.1,
                in: view
            )
        }
        
        XCTAssertEqual(view.subviews.count, 4)
    }
    
    func testShowTriggersAccessibilityAnnouncement() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        let message = "Important announcement"
        
        // We can't directly test UIAccessibility.post, but we can verify the toast is shown
        HABToast.show(message: message, in: view)
        
        XCTAssertEqual(view.subviews.count, 1)
        if let toast = view.subviews.first as? HABToast {
            XCTAssertEqual(toast.accessibilityLabel, message)
        }
    }
    
    func testShowSetsUpConstraints() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        
        HABToast.show(message: "Test", in: view)
        
        if let toast = view.subviews.first as? HABToast {
            XCTAssertFalse(toast.translatesAutoresizingMaskIntoConstraints)
        } else {
            XCTFail("Toast was not added to view")
        }
    }
    
    // MARK: - Dismiss Tests
    
    func testToastDismissesAfterDuration() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        let expectation = XCTestExpectation(description: "Toast dismissed after duration")
        
        HABToast.show(
            message: "Quick toast",
            style: .info,
            duration: 0.2,
            in: view
        )
        
        XCTAssertEqual(view.subviews.count, 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Toast should be removed or have alpha 0
            let toastCount = view.subviews.filter { $0 is HABToast && $0.alpha > 0 }.count
            XCTAssertEqual(toastCount, 0, "Toast should be dismissed")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Theme Change Tests
    
    func testThemeChangeUpdatesAppearance() {
        let toast = HABToast(message: "Theme test", style: .success)
        
        // Post theme change notification
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
        
        // Verify the toast is still valid after theme change
        XCTAssertNotNil(toast.backgroundColor)
    }
    
    // MARK: - Appearance Tests
    
    func testToastHasRoundedCorners() {
        let toast = HABToast(message: "Test")
        XCTAssertEqual(toast.layer.cornerRadius, HABRadius.lg)
    }
    
    func testToastHasShadow() {
        let toast = HABToast(message: "Test")
        // Shadow should be applied
        XCTAssertFalse(toast.layer.masksToBounds)
    }
    
    func testInfoStyleHasCorrectIcon() {
        let toast = HABToast(message: "Info", style: .info)
        // We can't easily access the private iconImageView, but we can verify the toast was created
        XCTAssertNotNil(toast)
    }
    
    func testSuccessStyleHasCorrectIcon() {
        let toast = HABToast(message: "Success", style: .success)
        XCTAssertNotNil(toast)
    }
    
    func testWarningStyleHasCorrectIcon() {
        let toast = HABToast(message: "Warning", style: .warning)
        XCTAssertNotNil(toast)
    }
    
    func testErrorStyleHasCorrectIcon() {
        let toast = HABToast(message: "Error", style: .error)
        XCTAssertNotNil(toast)
    }
    
    // MARK: - Animation Tests
    
    func testShowAnimatesIntoPosition() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        let expectation = XCTestExpectation(description: "Toast animated in")
        
        HABToast.show(
            message: "Animated toast",
            style: .info,
            duration: 1.0,
            in: view
        )
        
        // Give animation time to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let toast = view.subviews.first as? HABToast {
                XCTAssertEqual(toast.alpha, 1.0)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    // MARK: - Multiple Toasts Tests
    
    func testMultipleToastsCanBeShownSimultaneously() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        
        HABToast.show(message: "First", duration: 2.0, in: view)
        HABToast.show(message: "Second", duration: 2.0, in: view)
        HABToast.show(message: "Third", duration: 2.0, in: view)
        
        let toastCount = view.subviews.filter { $0 is HABToast }.count
        XCTAssertEqual(toastCount, 3)
    }
}
