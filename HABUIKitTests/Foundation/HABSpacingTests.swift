//
//  HABSpacingTests.swift
//  HABUIKitTests
//
//  Tests for HABSpacing — locks exact values so an accidental token change
//  produces a test failure rather than a silent layout shift.
//

import XCTest
import HABUIKit

final class HABSpacingTests: XCTestCase {
    func testExactValues() {
        XCTAssertEqual(HABSpacing.xxs, 2)
        XCTAssertEqual(HABSpacing.xs, 4)
        XCTAssertEqual(HABSpacing.sm, 8)
        XCTAssertEqual(HABSpacing.md, 16)
        XCTAssertEqual(HABSpacing.lg, 24)
        XCTAssertEqual(HABSpacing.xl, 32)
        XCTAssertEqual(HABSpacing.xxl, 48)
        XCTAssertEqual(HABSpacing.xxxl, 64)
    }

    func testStrictlyIncreasing() {
        let scale: [CGFloat] = [
            HABSpacing.xxs, HABSpacing.xs, HABSpacing.sm, HABSpacing.md,
            HABSpacing.lg, HABSpacing.xl, HABSpacing.xxl, HABSpacing.xxxl
        ]
        for index in scale.indices.dropFirst() {
            XCTAssertLessThan(scale[index - 1], scale[index], "Scale must be strictly increasing")
        }
    }
}
