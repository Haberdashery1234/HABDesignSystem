//
//  HABProgressBarTests.swift
//  HABUIKitTests
//
//  Tests for HABProgressBar.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABProgressBarTests: XCTestCase {
    func testDefaults() {
        let bar = HABProgressBar()
        XCTAssertEqual(bar.progress, 0)
        XCTAssertEqual(bar.tint, .primary)
        XCTAssertEqual(bar.intrinsicContentSize.height, 8)
    }

    func testProgressIsClamped() {
        let bar = HABProgressBar(progress: 1.5)
        XCTAssertEqual(bar.progress, 1)
        bar.progress = -1
        XCTAssertEqual(bar.progress, 0)
        bar.progress = .nan
        XCTAssertEqual(bar.progress, 0)
    }

    func testFillMatchesProgress() {
        let bar = HABProgressBar(progress: 0.25)
        bar.frame = CGRect(x: 0, y: 0, width: 200, height: 8)
        bar.layoutIfNeeded()
        XCTAssertEqual(bar.subviews.first?.frame.width ?? 0, 50, accuracy: 0.5)
    }

    func testVoiceOverReadsPercentage() {
        let bar = HABProgressBar(progress: 0.75)
        XCTAssertTrue(bar.isAccessibilityElement)
        XCTAssertEqual(bar.accessibilityValue, 0.75.formatted(.percent.precision(.fractionLength(0))))
    }

    func testCustomAccessibilityValue() {
        let bar = HABProgressBar(progress: 0.75)
        bar.accessibilityValue = "3 of 4 taken"
        XCTAssertEqual(bar.accessibilityValue, "3 of 4 taken")
        bar.accessibilityValue = nil
        XCTAssertNotEqual(bar.accessibilityValue, "3 of 4 taken")
    }

    func testBarHeightChangesIntrinsicSize() {
        let bar = HABProgressBar()
        bar.barHeight = 4
        XCTAssertEqual(bar.intrinsicContentSize.height, 4)
    }

    func testSetProgressAnimatedWithoutWindowJumps() {
        let bar = HABProgressBar()
        bar.setProgress(0.5, animated: true)
        XCTAssertEqual(bar.progress, 0.5)
    }
}
