//
//  HABLoadingViewTests.swift
//  HABUIKitTests
//
//  Tests for HABLoadingView.
//

import XCTest
import HABUIKit

final class HABLoadingViewTests: XCTestCase {
    func testDefaultStyle() {
        let view = HABLoadingView()
        XCTAssertEqual(view.style, .spinner)
    }

    func testInitWithLinearStyle() {
        let view = HABLoadingView(style: .linear)
        XCTAssertEqual(view.style, .linear)
    }

    func testStyleMutation() {
        let view = HABLoadingView(style: .spinner)
        view.style = .linear
        XCTAssertEqual(view.style, .linear)
    }

    func testDefaultMessageIsNil() {
        let view = HABLoadingView()
        XCTAssertNil(view.message)
    }

    func testInitWithMessage() {
        let view = HABLoadingView(message: "Loading…")
        XCTAssertEqual(view.message, "Loading…")
    }

    func testMessageMutation() {
        let view = HABLoadingView()
        view.message = "Please wait"
        XCTAssertEqual(view.message, "Please wait")
    }

    func testClearingMessage() {
        let view = HABLoadingView(message: "Loading…")
        view.message = nil
        XCTAssertNil(view.message)
    }

    func testDefaultProgressIsNil() {
        let view = HABLoadingView()
        XCTAssertNil(view.progress)
    }

    func testProgressMutation() {
        let view = HABLoadingView(style: .linear)
        view.progress = 0.5
        XCTAssertEqual(view.progress, 0.5)
    }

    func testClearingProgress() {
        let view = HABLoadingView(style: .linear)
        view.progress = 0.75
        view.progress = nil
        XCTAssertNil(view.progress)
    }

    func testAccessibilityTraits() {
        let view = HABLoadingView()
        XCTAssertTrue(view.accessibilityTraits.contains(.updatesFrequently))
    }

    func testAccessibilityLabelDefaultsToLoading() {
        let view = HABLoadingView()
        XCTAssertEqual(view.accessibilityLabel, "Loading")
    }

    func testAccessibilityLabelReflectsMessage() {
        let view = HABLoadingView(message: "Syncing data")
        XCTAssertEqual(view.accessibilityLabel, "Syncing data")
    }

    func testAccessibilityValueWithProgress() {
        let view = HABLoadingView(style: .linear)
        view.progress = 0.5
        XCTAssertEqual(view.accessibilityValue, "50 percent")
    }

    func testAccessibilityValueNilWhenNoProgress() {
        let view = HABLoadingView()
        XCTAssertNil(view.accessibilityValue)
    }
}
