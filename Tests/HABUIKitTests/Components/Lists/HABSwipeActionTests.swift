//
//  HABSwipeActionTests.swift
//  HABUIKitTests
//
//  Tests for HABSwipeActionStyle and UIContextualAction.hab.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABSwipeActionTests: XCTestCase {
    func testStylesUseSemanticColors() {
        XCTAssertIdentical(HABSwipeActionStyle.success.backgroundColor, UIColor.habSuccess)
        XCTAssertIdentical(HABSwipeActionStyle.warning.backgroundColor, UIColor.habWarning)
        XCTAssertIdentical(HABSwipeActionStyle.destructive.backgroundColor, UIColor.habDestructive)
    }

    func testNeutralIsOpaque() {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        var alpha: CGFloat = 0
        HABSwipeActionStyle.neutral.backgroundColor
            .resolvedColor(with: traits)
            .getRed(nil, green: nil, blue: nil, alpha: &alpha)
        XCTAssertEqual(alpha, 1, accuracy: 0.001)
    }

    func testFactorySetsTitleImageAndColor() {
        let image = UIImage(systemName: "checkmark")
        let action = UIContextualAction.hab(.success, title: "Taken", image: image) { _, _, done in done(true) }
        XCTAssertEqual(action.title, "Taken")
        XCTAssertEqual(action.image, image)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        XCTAssertEqual(
            action.backgroundColor.resolvedColor(with: traits),
            UIColor.habSuccess.resolvedColor(with: traits)
        )
        XCTAssertEqual(action.style, .normal)
    }

    func testRemovesRowUsesDestructiveStyle() {
        let action = UIContextualAction.hab(.destructive, title: "Delete", removesRow: true) { _, _, done in done(true) }
        XCTAssertEqual(action.style, .destructive)
    }

    func testEveryStyleHasAColor() {
        for style in HABSwipeActionStyle.allCases {
            XCTAssertNotNil(style.backgroundColor)
        }
    }
}
