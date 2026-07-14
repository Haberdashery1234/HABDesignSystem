//
//  HABShadowTests.swift
//  HABUIKitTests
//
//  Tests for HABShadow.
//

import XCTest
import HABUIKit

final class HABShadowTests: XCTestCase {
    func testNoneIsInvisible() {
        XCTAssertEqual(HABShadow.none.opacity, 0)
        XCTAssertEqual(HABShadow.none.radius, 0)
        XCTAssertEqual(HABShadow.none.offset, .zero)
    }

    func testOpacityStrictlyIncreases() {
        XCTAssertLessThan(HABShadow.none.opacity, HABShadow.low.opacity)
        XCTAssertLessThan(HABShadow.low.opacity, HABShadow.medium.opacity)
        XCTAssertLessThan(HABShadow.medium.opacity, HABShadow.high.opacity)
        XCTAssertLessThan(HABShadow.high.opacity, HABShadow.overlay.opacity)
    }

    func testRadiusStrictlyIncreases() {
        XCTAssertLessThan(HABShadow.none.radius, HABShadow.low.radius)
        XCTAssertLessThan(HABShadow.low.radius, HABShadow.medium.radius)
        XCTAssertLessThan(HABShadow.medium.radius, HABShadow.high.radius)
        XCTAssertLessThan(HABShadow.high.radius, HABShadow.overlay.radius)
    }

    func testApplyWritesToLayer() {
        let layer = CALayer()
        HABShadow.medium.apply(to: layer)

        XCTAssertFalse(layer.masksToBounds)
        XCTAssertEqual(layer.shadowOpacity, HABShadow.medium.opacity)
        XCTAssertEqual(layer.shadowRadius, HABShadow.medium.radius)
        XCTAssertEqual(layer.shadowOffset, HABShadow.medium.offset)
    }

    func testClearRemovesShadow() {
        let layer = CALayer()
        HABShadow.overlay.apply(to: layer)
        XCTAssertGreaterThan(layer.shadowOpacity, 0)

        HABShadowStyle.clear(layer)
        XCTAssertEqual(layer.shadowOpacity, 0)
    }
}
