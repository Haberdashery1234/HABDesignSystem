//
//  HABTextFieldTests.swift
//  HABUIKitTests
//
//  Tests for HABTextField.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABTextFieldTests: XCTestCase {
    func testDefaultStyle() {
        let field = HABTextField()
        XCTAssertEqual(field.style, .outlined)
    }

    func testTextRoundtrip() {
        let field = HABTextField()
        field.text = "hello"
        XCTAssertEqual(field.text, "hello")
    }

    func testEmptyTextReturnsEmptyString() {
        let field = HABTextField()
        XCTAssertEqual(field.text, "")
    }

    func testPlaceholderRoundtrip() {
        let field = HABTextField()
        field.placeholder = "Enter email"
        XCTAssertEqual(field.placeholder, "Enter email")
    }

    func testIsDisabledDefault() {
        let field = HABTextField()
        XCTAssertFalse(field.isDisabled)
    }

    func testIsDisabledMutation() {
        let field = HABTextField()
        field.isDisabled = true
        XCTAssertTrue(field.isDisabled)
    }

    func testStyleMutation() {
        let field = HABTextField()
        field.style = .filled
        XCTAssertEqual(field.style, .filled)
    }

    func testTopLabelMutation() {
        let field = HABTextField()
        field.topLabel = "Email"
        XCTAssertEqual(field.topLabel, "Email")
    }

    func testHelperTextMutation() {
        let field = HABTextField()
        field.helperText = "We'll never share your email"
        XCTAssertEqual(field.helperText, "We'll never share your email")
    }

    func testErrorTextMutation() {
        let field = HABTextField()
        field.errorText = "Invalid email"
        XCTAssertEqual(field.errorText, "Invalid email")
    }

    func testClearingErrorText() {
        let field = HABTextField()
        field.errorText = "Error"
        field.errorText = nil
        XCTAssertNil(field.errorText)
    }

    func testKeyboardTypeRoundtrip() {
        let field = HABTextField()
        field.keyboardType = .emailAddress
        XCTAssertEqual(field.keyboardType, .emailAddress)
    }

    func testSecureTextEntryDefault() {
        let field = HABTextField()
        XCTAssertFalse(field.isSecureTextEntry)
    }

    func testSecureTextEntryMutation() {
        let field = HABTextField()
        field.isSecureTextEntry = true
        XCTAssertTrue(field.isSecureTextEntry)
    }

    func testReturnKeyTypeMutation() {
        let field = HABTextField()
        field.returnKeyType = .done
        XCTAssertEqual(field.returnKeyType, .done)
    }

    func testAutocapitalizationMutation() {
        let field = HABTextField()
        field.autocapitalizationType = .none
        XCTAssertEqual(field.autocapitalizationType, .none)
    }

    func testAutocorrectionMutation() {
        let field = HABTextField()
        field.autocorrectionType = .no
        XCTAssertEqual(field.autocorrectionType, .no)
    }

    func testLeadingIconMutation() {
        let field = HABTextField()
        field.leadingIcon = UIImage(systemName: "envelope")
        XCTAssertNotNil(field.leadingIcon)
    }

    func testClearingLeadingIcon() {
        let field = HABTextField()
        field.leadingIcon = UIImage(systemName: "envelope")
        field.leadingIcon = nil
        XCTAssertNil(field.leadingIcon)
    }

    func testTrailingIconMutation() {
        let field = HABTextField()
        field.trailingIcon = UIImage(systemName: "eye")
        XCTAssertNotNil(field.trailingIcon)
    }

    // MARK: - UITextFieldDelegate forwarding

    func testTextFieldShouldReturnDefaultsToTrue() {
        let field = HABTextField()
        let dummy = UITextField()
        XCTAssertTrue(field.textFieldShouldReturn(dummy))
    }

    func testTextFieldShouldReturnForwardsToDelegateAndReturnsItsValue() {
        class MockDelegate: NSObject, UITextFieldDelegate {
            var called = false
            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                called = true
                return false
            }
        }
        let field = HABTextField()
        let mock = MockDelegate()
        field.delegate = mock
        let result = field.textFieldShouldReturn(UITextField())
        XCTAssertTrue(mock.called)
        XCTAssertFalse(result)
    }

    func testTextFieldShouldChangeCharactersDefaultsToTrue() {
        let field = HABTextField()
        let result = field.textField(
            UITextField(),
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "a"
        )
        XCTAssertTrue(result)
    }

    func testTextFieldDidBeginEditingDoesNotCrash() {
        let field = HABTextField()
        field.textFieldDidBeginEditing(UITextField())
    }

    func testTextFieldDidBeginEditingForwardsToDelegateBeginEditing() {
        class MockDelegate: NSObject, UITextFieldDelegate {
            var called = false
            func textFieldDidBeginEditing(_ textField: UITextField) { called = true }
        }
        let field = HABTextField()
        let mock = MockDelegate()
        field.delegate = mock
        field.textFieldDidBeginEditing(UITextField())
        XCTAssertTrue(mock.called)
    }

    func testTextFieldDidEndEditingDoesNotCrash() {
        let field = HABTextField()
        field.textFieldDidEndEditing(UITextField())
    }

    func testTextFieldDidEndEditingForwardsToDelegateEndEditing() {
        class MockDelegate: NSObject, UITextFieldDelegate {
            var called = false
            func textFieldDidEndEditing(_ textField: UITextField) { called = true }
        }
        let field = HABTextField()
        let mock = MockDelegate()
        field.delegate = mock
        field.textFieldDidEndEditing(UITextField())
        XCTAssertTrue(mock.called)
    }

    // MARK: - Layout regressions

    func testUsesThemeBodyFontWithDynamicType() {
        let field = HABTextField()
        let inner = field.firstSubview(of: UITextField.self)
        XCTAssertEqual(inner?.font, UIFont.habBody)
        XCTAssertTrue(inner?.adjustsFontForContentSizeCategory ?? false)
    }

    func testFieldHeightIsAMinimumNotFixed() {
        let field = HABTextField()
        let fixed48 = field.allConstraintsInHierarchy().contains {
            $0.firstAttribute == .height && $0.relation == .equal && $0.constant == 48
        }
        XCTAssertFalse(fixed48, "A fixed 48pt height clips text at large Dynamic Type sizes")
    }
}

private extension UIView {
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        for sub in subviews {
            if let match = sub as? T { return match }
            if let match = sub.firstSubview(of: type) { return match }
        }
        return nil
    }

    func allConstraintsInHierarchy() -> [NSLayoutConstraint] {
        constraints + subviews.flatMap { $0.allConstraintsInHierarchy() }
    }
}
