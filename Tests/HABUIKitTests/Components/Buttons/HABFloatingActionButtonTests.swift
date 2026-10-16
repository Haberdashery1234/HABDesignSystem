//
//  HABFloatingActionButtonTests.swift
//  HABUIKitTests
//
//  Tests for HABFloatingActionButton.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABFloatingActionButtonTests: XCTestCase {
    private func makeButton(onTap: @escaping () -> Void = {}) -> HABFloatingActionButton {
        HABFloatingActionButton(
            icon: UIImage(systemName: "plus"),
            action: HABAccessibleAction(label: "Add Medication", action: onTap)
        )
    }

    func testActionLabelIsTheVoiceOverLabel() {
        let button = makeButton()
        XCTAssertEqual(button.accessibilityLabel, "Add Medication")
        XCTAssertTrue(button.accessibilityTraits.contains(.button))
    }

    func testTapRunsAction() {
        var tapped = false
        let button = makeButton { tapped = true }
        button.simulate(.touchUpInside)
        XCTAssertTrue(tapped)
    }

    func testIs56PointsTall() {
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let button = makeButton()
        button.install(in: host)
        host.layoutIfNeeded()
        XCTAssertEqual(button.bounds.height, 56, accuracy: 0.5)
        XCTAssertGreaterThanOrEqual(button.bounds.width, 56)
    }

    func testHasAShadow() {
        let button = makeButton()
        XCTAssertGreaterThan(button.layer.shadowOpacity, 0)
    }

    func testInstallInPlainView() {
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let button = makeButton()
        button.install(in: host)
        XCTAssertIdentical(button.superview, host)
        host.layoutIfNeeded()
        XCTAssertEqual(button.frame.maxY, 480 - HABSpacing.md, accuracy: 0.5)
        XCTAssertEqual(button.frame.maxX, 320 - HABSpacing.md, accuracy: 0.5)
    }

    func testInstallInScrollViewAddsInsetAndUninstallRemovesIt() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        scrollView.contentInset.bottom = 10
        let button = makeButton()
        button.install(in: scrollView)
        XCTAssertGreaterThan(scrollView.contentInset.bottom, 10)

        button.uninstall()
        XCTAssertNil(button.superview)
        XCTAssertEqual(scrollView.contentInset.bottom, 10)
    }

    func testStaysPutWhenScrollViewScrolls() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let scrollView = UIScrollView(frame: window.bounds)
        scrollView.contentSize = CGSize(width: 320, height: 2000)
        window.addSubview(scrollView)
        window.isHidden = false
        let button = makeButton()
        button.install(in: scrollView)
        scrollView.layoutIfNeeded()
        // Distance from the top of the visible area, which shouldn't change as content scrolls.
        let before = button.frame.minY - scrollView.contentOffset.y
        XCTAssertGreaterThan(before, 0, "The button should be laid out inside the visible area")

        scrollView.contentOffset.y = 300
        scrollView.layoutIfNeeded()
        let after = button.frame.minY - scrollView.contentOffset.y
        XCTAssertEqual(before, after, accuracy: 0.5)
        window.isHidden = true
    }

    func testUpdatePlacementBringsButtonToFront() {
        let host = UIView()
        let button = makeButton()
        button.install(in: host)
        host.addSubview(UIView())
        button.updatePlacement()
        XCTAssertIdentical(host.subviews.last, button)
    }

    func testBaseViewControllerInstallsButton() {
        let controller = HABBaseViewController()
        let button = makeButton()
        controller.floatingActionButton = button
        controller.loadViewIfNeeded()
        XCTAssertIdentical(button.superview, controller.view)
    }
}
