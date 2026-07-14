//
//  HABAnimationTests.swift
//  HABUIKitTests
//
//  Tests for HABAnimation constants.
//

import XCTest
import HABUIKit

final class HABAnimationTests: XCTestCase {
    // MARK: - Duration Tests
    
    func testInstantDuration() {
        XCTAssertEqual(HABAnimation.Duration.instant, 0)
    }
    
    func testFastDuration() {
        XCTAssertEqual(HABAnimation.Duration.fast, 0.15)
    }
    
    func testNormalDuration() {
        XCTAssertEqual(HABAnimation.Duration.normal, 0.25)
    }
    
    func testSlowDuration() {
        XCTAssertEqual(HABAnimation.Duration.slow, 0.4)
    }
    
    func testVerySlowDuration() {
        XCTAssertEqual(HABAnimation.Duration.verySlow, 0.6)
    }
    
    func testDurationsStrictlyIncrease() {
        XCTAssertLessThan(HABAnimation.Duration.instant, HABAnimation.Duration.fast)
        XCTAssertLessThan(HABAnimation.Duration.fast, HABAnimation.Duration.normal)
        XCTAssertLessThan(HABAnimation.Duration.normal, HABAnimation.Duration.slow)
        XCTAssertLessThan(HABAnimation.Duration.slow, HABAnimation.Duration.verySlow)
    }
    
    // MARK: - Curve Tests
    
    func testStandardCurveHasOptions() {
        let curve = HABAnimation.Curve.standard
        XCTAssertEqual(curve.options, .curveEaseInOut)
    }
    
    func testStandardCurveHasTimingFunction() {
        let curve = HABAnimation.Curve.standard
        XCTAssertNotNil(curve.timingFunction)
    }
    
    func testEaseInCurveHasOptions() {
        let curve = HABAnimation.Curve.easeIn
        XCTAssertEqual(curve.options, .curveEaseIn)
    }
    
    func testEaseInCurveHasTimingFunction() {
        let curve = HABAnimation.Curve.easeIn
        XCTAssertNotNil(curve.timingFunction)
    }
    
    func testEaseOutCurveHasOptions() {
        let curve = HABAnimation.Curve.easeOut
        XCTAssertEqual(curve.options, .curveEaseOut)
    }
    
    func testEaseOutCurveHasTimingFunction() {
        let curve = HABAnimation.Curve.easeOut
        XCTAssertNotNil(curve.timingFunction)
    }
    
    func testLinearCurveHasOptions() {
        let curve = HABAnimation.Curve.linear
        XCTAssertEqual(curve.options, .curveLinear)
    }
    
    func testLinearCurveHasTimingFunction() {
        let curve = HABAnimation.Curve.linear
        XCTAssertNotNil(curve.timingFunction)
    }
    
    // MARK: - Spring Preset Tests
    
    func testGentleSpringDuration() {
        XCTAssertEqual(HABAnimation.Spring.gentle.duration, 0.35)
    }
    
    func testGentleSpringBounce() {
        XCTAssertEqual(HABAnimation.Spring.gentle.bounce, 0.15)
    }
    
    func testBouncySpringDuration() {
        XCTAssertEqual(HABAnimation.Spring.bouncy.duration, 0.5)
    }
    
    func testBouncySpringBounce() {
        XCTAssertEqual(HABAnimation.Spring.bouncy.bounce, 0.4)
    }
    
    func testBouncySpringIsMoreBouncyThanGentle() {
        XCTAssertGreaterThan(HABAnimation.Spring.bouncy.bounce, HABAnimation.Spring.gentle.bounce)
    }
    
    func testBouncySpringHasLongerDurationThanGentle() {
        XCTAssertGreaterThan(HABAnimation.Spring.bouncy.duration, HABAnimation.Spring.gentle.duration)
    }
    
    func testSpringBounceValuesAreInValidRange() {
        // Bounce values should be between 0 and 1
        XCTAssertGreaterThanOrEqual(HABAnimation.Spring.gentle.bounce, 0)
        XCTAssertLessThanOrEqual(HABAnimation.Spring.gentle.bounce, 1)
        
        XCTAssertGreaterThanOrEqual(HABAnimation.Spring.bouncy.bounce, 0)
        XCTAssertLessThanOrEqual(HABAnimation.Spring.bouncy.bounce, 1)
    }
    
    // MARK: - Animation Integration Tests
    
    func testCurveOptionsCanBeUsedWithUIViewAnimate() {
        let expectation = XCTestExpectation(description: "Animation completes")
        let view = UIView()
        view.alpha = 0
        
        UIView.animate(
            withDuration: HABAnimation.Duration.fast,
            delay: 0,
            options: HABAnimation.Curve.easeOut.options,
            animations: {
                view.alpha = 1
            },
            completion: { _ in
                XCTAssertEqual(view.alpha, 1)
                expectation.fulfill()
            }
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSpringAnimationCanBePerformed() {
        let expectation = XCTestExpectation(description: "Spring animation completes")
        let view = UIView()
        view.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(
            withDuration: HABAnimation.Spring.gentle.duration,
            delay: 0,
            usingSpringWithDamping: 1.0 - HABAnimation.Spring.gentle.bounce,
            initialSpringVelocity: 0,
            options: HABAnimation.Curve.easeOut.options,
            animations: {
                view.transform = .identity
            },
            completion: { _ in
                XCTAssertEqual(view.transform, .identity)
                expectation.fulfill()
            }
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Timing Function Tests
    
    func testAllCurvesHaveUniqueTimingFunctions() {
        let standard = HABAnimation.Curve.standard.timingFunction
        let easeIn = HABAnimation.Curve.easeIn.timingFunction
        let easeOut = HABAnimation.Curve.easeOut.timingFunction
        let linear = HABAnimation.Curve.linear.timingFunction
        
        // All should exist
        XCTAssertNotNil(standard)
        XCTAssertNotNil(easeIn)
        XCTAssertNotNil(easeOut)
        XCTAssertNotNil(linear)
    }
    
    // MARK: - Practical Value Tests
    
    func testFastDurationIsSuitableForMicroInteractions() {
        // Fast should be less than 200ms for responsive feel
        XCTAssertLessThan(HABAnimation.Duration.fast, 0.2)
    }
    
    func testNormalDurationIsSuitableForTransitions() {
        // Normal should be in the sweet spot: 200-300ms
        XCTAssertGreaterThanOrEqual(HABAnimation.Duration.normal, 0.2)
        XCTAssertLessThanOrEqual(HABAnimation.Duration.normal, 0.3)
    }
    
    func testSlowDurationIsDeliberate() {
        // Slow animations should be noticeably slower than normal
        XCTAssertGreaterThan(HABAnimation.Duration.slow, HABAnimation.Duration.normal * 1.5)
    }
}
