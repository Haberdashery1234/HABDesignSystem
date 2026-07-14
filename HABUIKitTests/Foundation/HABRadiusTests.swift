//
//  HABRadiusTests.swift
//  HABUIKitTests
//
//  Tests for HABRadius — locks exact values so an accidental token change
//  produces a test failure rather than a silent layout shift.
//

import XCTest
import HABUIKit

final class HABRadiusTests: XCTestCase {
    func testExactValues() {
        XCTAssertEqual(HABRadius.none, 0)
        XCTAssertEqual(HABRadius.xs, 4)
        XCTAssertEqual(HABRadius.sm, 8)
        XCTAssertEqual(HABRadius.md, 12)
        XCTAssertEqual(HABRadius.lg, 16)
        XCTAssertEqual(HABRadius.xl, 24)
        XCTAssertEqual(HABRadius.pill, 9999)
    }

    func testStrictlyIncreasing() {
        let scale: [CGFloat] = [
            HABRadius.none, HABRadius.xs, HABRadius.sm, HABRadius.md,
            HABRadius.lg, HABRadius.xl, HABRadius.pill
        ]
        for index in scale.indices.dropFirst() {
            XCTAssertLessThan(scale[index - 1], scale[index], "Scale must be strictly increasing")
        }
    }
}
