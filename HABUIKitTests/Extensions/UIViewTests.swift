//
//  UIViewTests.swift
//  HABUIKitTests
//
//  Tests for UIView+HAB extensions.
//

import XCTest
import HABUIKit

final class UIViewTests: XCTestCase {
    // MARK: - addSubviews

    func testAddSubviewsAddsAll() {
        let parent = UIView()
        let child1 = UIView(), child2 = UIView(), child3 = UIView()
        parent.addSubviews(child1, child2, child3)
        XCTAssertEqual(parent.subviews.count, 3)
    }

    func testAddSubviewsSingle() {
        let parent = UIView()
        let child = UIView()
        parent.addSubviews(child)
        XCTAssertEqual(parent.subviews.count, 1)
    }

    // MARK: - pinToSuperview

    func testPinToSuperviewDisablesAutoresizing() {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        child.pinToSuperview()
        XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints)
    }

    func testPinToSuperviewAddsConstraints() {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        child.pinToSuperview()
        XCTAssertFalse(parent.constraints.isEmpty)
    }

    func testPinToSuperviewWithoutSuperviewDoesNotCrash() {
        let orphan = UIView()
        orphan.pinToSuperview() // should be a no-op, not a crash
    }

    // MARK: - pinToSuperviewSafeArea

    func testPinToSuperviewSafeAreaDisablesAutoresizing() {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        child.pinToSuperviewSafeArea()
        XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints)
    }

    func testPinToSuperviewSafeAreaWithoutSuperviewDoesNotCrash() {
        let orphan = UIView()
        orphan.pinToSuperviewSafeArea()
    }

    // MARK: - centerInSuperview

    func testCenterInSuperviewDisablesAutoresizing() {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        child.centerInSuperview()
        XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints)
    }

    func testCenterInSuperviewAddsConstraints() {
        let parent = UIView()
        let child = UIView()
        parent.addSubview(child)
        child.centerInSuperview()
        XCTAssertFalse(parent.constraints.isEmpty)
    }

    func testCenterInSuperviewWithoutSuperviewDoesNotCrash() {
        let orphan = UIView()
        orphan.centerInSuperview()
    }

    // MARK: - constrainSize

    func testConstrainSizeWidthAddsConstraint() {
        let view = UIView()
        view.constrainSize(width: 100)
        let widthConstraints = view.constraints.filter { $0.firstAttribute == .width }
        XCTAssertEqual(widthConstraints.count, 1)
        XCTAssertEqual(widthConstraints.first?.constant, 100)
    }

    func testConstrainSizeHeightAddsConstraint() {
        let view = UIView()
        view.constrainSize(height: 50)
        let heightConstraints = view.constraints.filter { $0.firstAttribute == .height }
        XCTAssertEqual(heightConstraints.count, 1)
        XCTAssertEqual(heightConstraints.first?.constant, 50)
    }

    func testConstrainSizeBothAddsConstraints() {
        let view = UIView()
        view.constrainSize(width: 80, height: 40)
        XCTAssertEqual(view.constraints.count, 2)
    }

    func testConstrainSizeDisablesAutoresizing() {
        let view = UIView()
        view.constrainSize(width: 100)
        XCTAssertFalse(view.translatesAutoresizingMaskIntoConstraints)
    }

    // MARK: - applyShadow

    func testApplyShadowWritesToLayer() {
        let view = UIView()
        view.applyShadow(HABShadow.medium)
        XCTAssertEqual(view.layer.shadowOpacity, HABShadow.medium.opacity)
        XCTAssertEqual(view.layer.shadowRadius, HABShadow.medium.radius)
    }

    // MARK: - fadeIn / fadeOut

    func testFadeInDoesNotCrash() {
        let view = UIView()
        view.fadeIn(duration: 0)
        // Reaching here means no exception was thrown.
    }

    func testFadeOutHidesViewOnCompletion() {
        let exp = expectation(description: "fadeOut completion")
        let view = UIView()
        view.fadeOut(duration: 0) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertTrue(view.isHidden)
    }

    // MARK: - roundCorners

    func testRoundCornersDoesNotCrash() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.roundCorners([.topLeft, .topRight], radius: 8)
        XCTAssertNotNil(view.layer.mask)
    }
}
