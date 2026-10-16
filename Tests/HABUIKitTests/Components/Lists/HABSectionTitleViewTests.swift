//
//  HABSectionTitleViewTests.swift
//  HABUIKitTests
//
//  Tests for HABSectionTitleView and HABSectionHeaderFooterView.
//

import XCTest
import HABUIKit
import HABFoundation

final class HABSectionTitleViewTests: XCTestCase {
    func testHeaderIsAHeading() {
        let view = HABSectionTitleView(kind: .header, text: "Today")
        XCTAssertTrue(view.isAccessibilityElement)
        XCTAssertTrue(view.accessibilityTraits.contains(.header))
        XCTAssertEqual(view.accessibilityLabel, "Today")
    }

    func testFooterIsNotAHeading() {
        let view = HABSectionTitleView(kind: .footer, text: "Doses use your time zone.")
        XCTAssertFalse(view.accessibilityTraits.contains(.header))
    }

    func testDetailIsReadAfterText() {
        let view = HABSectionTitleView(kind: .header, text: "Today", detail: "3 of 4 taken")
        XCTAssertEqual(view.accessibilityLabel, "Today, 3 of 4 taken")
    }

    func testChangingKindUpdatesTraits() {
        let view = HABSectionTitleView(kind: .header, text: "Notes")
        view.kind = .footer
        XCTAssertFalse(view.accessibilityTraits.contains(.header))
    }

    func testDetailLabelHiddenWithoutDetail() {
        let view = HABSectionTitleView(kind: .header, text: "Today")
        let labels = view.descendants(of: UILabel.self)
        XCTAssertEqual(labels.filter { !$0.isHidden }.count, 1)
    }

    func testHeaderFooterViewConfigure() {
        let view = HABSectionHeaderFooterView(reuseIdentifier: HABSectionHeaderFooterView.reuseIdentifier)
        view.configure(kind: .footer, text: "Footer", detail: "Detail")
        XCTAssertEqual(view.titleView.kind, .footer)
        XCTAssertEqual(view.titleView.text, "Footer")
        XCTAssertEqual(view.titleView.detail, "Detail")
    }

    func testHeaderFooterViewResetsOnReuse() {
        let view = HABSectionHeaderFooterView(reuseIdentifier: HABSectionHeaderFooterView.reuseIdentifier)
        view.configure(kind: .footer, text: "Footer")
        view.prepareForReuse()
        XCTAssertEqual(view.titleView.kind, .header)
        XCTAssertNil(view.titleView.text)
    }
}
