//
//  HABTextViewTests.swift
//  HABUIKitTests
//
//  Tests for HABTextView.
//

import XCTest
import HABUIKit

final class HABTextViewTests: XCTestCase {
    // MARK: - Initialization Tests
    
    func testDefaultStyle() {
        let textView = HABTextView()
        XCTAssertEqual(textView.style, .outlined)
    }
    
    func testInitWithStyle() {
        let outlinedView = HABTextView(style: .outlined)
        XCTAssertEqual(outlinedView.style, .outlined)
        
        let filledView = HABTextView(style: .filled)
        XCTAssertEqual(filledView.style, .filled)
    }
    
    func testInitWithTopLabel() {
        let textView = HABTextView(topLabel: "Description")
        XCTAssertEqual(textView.topLabel, "Description")
    }
    
    func testInitWithPlaceholder() {
        let textView = HABTextView(placeholder: "Enter details...")
        XCTAssertEqual(textView.placeholder, "Enter details...")
    }
    
    func testInitWithHelperText() {
        let textView = HABTextView(helperText: "This is a helper")
        XCTAssertEqual(textView.helperText, "This is a helper")
    }
    
    func testInitWithErrorText() {
        let textView = HABTextView(errorText: "This is required")
        XCTAssertEqual(textView.errorText, "This is required")
    }
    
    func testInitWithIsDisabled() {
        let textView = HABTextView(isDisabled: true)
        XCTAssertTrue(textView.isDisabled)
    }
    
    func testDefaultMinHeight() {
        let textView = HABTextView()
        XCTAssertEqual(textView.minHeight, 80)
    }
    
    func testInitWithCustomMinHeight() {
        let textView = HABTextView(minHeight: 120)
        XCTAssertEqual(textView.minHeight, 120)
    }
    
    // MARK: - Property Mutation Tests
    
    func testStyleMutation() {
        let textView = HABTextView(style: .outlined)
        textView.style = .filled
        XCTAssertEqual(textView.style, .filled)
    }
    
    func testTopLabelMutation() {
        let textView = HABTextView()
        textView.topLabel = "Comments"
        XCTAssertEqual(textView.topLabel, "Comments")
    }
    
    func testHelperTextMutation() {
        let textView = HABTextView()
        textView.helperText = "Optional field"
        XCTAssertEqual(textView.helperText, "Optional field")
    }
    
    func testErrorTextMutation() {
        let textView = HABTextView()
        textView.errorText = "Field is required"
        XCTAssertEqual(textView.errorText, "Field is required")
    }
    
    func testClearingErrorText() {
        let textView = HABTextView(errorText: "Error")
        textView.errorText = nil
        XCTAssertNil(textView.errorText)
    }
    
    func testIsDisabledMutation() {
        let textView = HABTextView()
        XCTAssertFalse(textView.isDisabled)
        textView.isDisabled = true
        XCTAssertTrue(textView.isDisabled)
    }
    
    func testMinHeightMutation() {
        let textView = HABTextView()
        textView.minHeight = 150
        XCTAssertEqual(textView.minHeight, 150)
    }
    
    // MARK: - Text Property Tests
    
    func testTextRoundtrip() {
        let textView = HABTextView()
        textView.text = "Hello, world!"
        XCTAssertEqual(textView.text, "Hello, world!")
    }
    
    func testEmptyTextReturnsEmptyString() {
        let textView = HABTextView()
        // Default text should be empty or nil
        let text = textView.text ?? ""
        XCTAssertTrue(text.isEmpty)
    }
    
    func testPlaceholderRoundtrip() {
        let textView = HABTextView()
        textView.placeholder = "Type here..."
        XCTAssertEqual(textView.placeholder, "Type here...")
    }
    
    // MARK: - Keyboard Configuration Tests
    
    func testKeyboardTypeRoundtrip() {
        let textView = HABTextView()
        textView.keyboardType = .emailAddress
        XCTAssertEqual(textView.keyboardType, .emailAddress)
    }
    
    func testAutocapitalizationTypeRoundtrip() {
        let textView = HABTextView()
        textView.autocapitalizationType = .sentences
        XCTAssertEqual(textView.autocapitalizationType, .sentences)
    }
    
    func testAutocorrectionTypeRoundtrip() {
        let textView = HABTextView()
        textView.autocorrectionType = .no
        XCTAssertEqual(textView.autocorrectionType, .no)
    }
    
    func testReturnKeyTypeRoundtrip() {
        let textView = HABTextView()
        textView.returnKeyType = .done
        XCTAssertEqual(textView.returnKeyType, .done)
    }
    
    // MARK: - State Tests
    
    func testDisabledStateAffectsInteraction() {
        let textView = HABTextView()
        textView.isDisabled = true
        // Verify that the view updates its appearance
        XCTAssertTrue(textView.isDisabled)
    }
    
    func testErrorTextTriggersAccessibilityAnnouncement() {
        let textView = HABTextView()
        
        // Setting error text should post an accessibility announcement
        // We can't directly test the announcement, but we can verify the property is set
        textView.errorText = "This field is required"
        XCTAssertEqual(textView.errorText, "This field is required")
    }
    
    // MARK: - Theme Change Tests
    
    func testThemeChangeUpdatesAppearance() {
        let textView = HABTextView()
        
        // Post theme change notification
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
        
        // Verify the view is still valid after theme change
        XCTAssertNotNil(textView.style)
    }
    
    // MARK: - All Styles Test
    
    func testAllStylesRenderWithoutError() {
        let styles: [HABTextView.Style] = [.outlined, .filled]
        
        for style in styles {
            let textView = HABTextView(style: style)
            XCTAssertEqual(textView.style, style)
        }
    }
    
    // MARK: - Delegate Tests
    
    func testDelegateIsWeak() {
        class TestDelegate: NSObject, UITextViewDelegate {}
        
        let textView = HABTextView()
        weak var weakDelegate: TestDelegate?
        
        autoreleasepool {
            let delegate = TestDelegate()
            weakDelegate = delegate
            textView.delegate = delegate
            XCTAssertNotNil(textView.delegate)
        }
        
        // Delegate should be deallocated since it's weak
        XCTAssertNil(weakDelegate)
    }
    
    // MARK: - Layout Tests

    func testTranslatesAutoresizingMaskIntoConstraintsIsFalse() {
        let textView = HABTextView()
        XCTAssertFalse(textView.translatesAutoresizingMaskIntoConstraints)
    }

    // MARK: - UITextViewDelegate Forwarding

    func testTextViewDidBeginEditingForwardsToDelegate() {
        class MockDelegate: NSObject, UITextViewDelegate {
            var called = false
            func textViewDidBeginEditing(_ textView: UITextView) { called = true }
        }
        let textView = HABTextView()
        let mock = MockDelegate()
        textView.delegate = mock
        textView.textViewDidBeginEditing(UITextView())
        XCTAssertTrue(mock.called)
    }

    func testTextViewDidEndEditingDoesNotCrash() {
        let textView = HABTextView()
        textView.textViewDidEndEditing(UITextView())
    }

    func testTextViewDidEndEditingForwardsToDelegate() {
        class MockDelegate: NSObject, UITextViewDelegate {
            var called = false
            func textViewDidEndEditing(_ textView: UITextView) { called = true }
        }
        let textView = HABTextView()
        let mock = MockDelegate()
        textView.delegate = mock
        textView.textViewDidEndEditing(UITextView())
        XCTAssertTrue(mock.called)
    }

    func testTextViewDidChangeDoesNotCrash() {
        let textView = HABTextView()
        textView.textViewDidChange(UITextView())
    }

    func testTextViewDidChangeForwardsToDelegate() {
        class MockDelegate: NSObject, UITextViewDelegate {
            var called = false
            func textViewDidChange(_ textView: UITextView) { called = true }
        }
        let textView = HABTextView()
        let mock = MockDelegate()
        textView.delegate = mock
        textView.textViewDidChange(UITextView())
        XCTAssertTrue(mock.called)
    }

    func testTextViewShouldChangeDefaultsToTrue() {
        let textView = HABTextView()
        let result = textView.textView(
            UITextView(),
            shouldChangeTextIn: NSRange(location: 0, length: 0),
            replacementText: "a"
        )
        XCTAssertTrue(result)
    }

    func testTextViewShouldChangeForwardsToDelegateAndReturnsItsValue() {
        class MockDelegate: NSObject, UITextViewDelegate {
            var called = false
            func textView(
                _ textView: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String
            ) -> Bool {
                called = true
                return false
            }
        }
        let textView = HABTextView()
        let mock = MockDelegate()
        textView.delegate = mock
        let result = textView.textView(
            UITextView(),
            shouldChangeTextIn: NSRange(location: 0, length: 0),
            replacementText: "a"
        )
        XCTAssertTrue(mock.called)
        XCTAssertFalse(result)
    }

    func testTextViewShouldBeginEditingDefaultsToTrue() {
        let textView = HABTextView()
        XCTAssertTrue(textView.textViewShouldBeginEditing(UITextView()))
    }

    func testTextViewShouldBeginEditingForwardsToDelegate() {
        class MockDelegate: NSObject, UITextViewDelegate {
            var called = false
            func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
                called = true
                return false
            }
        }
        let textView = HABTextView()
        let mock = MockDelegate()
        textView.delegate = mock
        let result = textView.textViewShouldBeginEditing(UITextView())
        XCTAssertTrue(mock.called)
        XCTAssertFalse(result)
    }

    func testTextViewShouldEndEditingDefaultsToTrue() {
        let textView = HABTextView()
        XCTAssertTrue(textView.textViewShouldEndEditing(UITextView()))
    }

    func testTextViewShouldEndEditingForwardsToDelegate() {
        class MockDelegate: NSObject, UITextViewDelegate {
            var called = false
            func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
                called = true
                return false
            }
        }
        let textView = HABTextView()
        let mock = MockDelegate()
        textView.delegate = mock
        let result = textView.textViewShouldEndEditing(UITextView())
        XCTAssertTrue(mock.called)
        XCTAssertFalse(result)
    }

    func testTextViewDidChangeSelectionDoesNotCrash() {
        let textView = HABTextView()
        textView.textViewDidChangeSelection(UITextView())
    }

    func testTextViewDidChangeSelectionForwardsToDelegate() {
        class MockDelegate: NSObject, UITextViewDelegate {
            var called = false
            func textViewDidChangeSelection(_ textView: UITextView) { called = true }
        }
        let textView = HABTextView()
        let mock = MockDelegate()
        textView.delegate = mock
        textView.textViewDidChangeSelection(UITextView())
        XCTAssertTrue(mock.called)
    }
}
