//
//  HABAvatarTests.swift
//  HABUIKitTests
//
//  Tests for HABAvatar.
//

import XCTest
import HABUIKit

final class HABAvatarTests: XCTestCase {
    func testSizePoints() {
        XCTAssertEqual(HABAvatar.Size.small.points, 32)
        XCTAssertEqual(HABAvatar.Size.medium.points, 40)
        XCTAssertEqual(HABAvatar.Size.large.points, 56)
    }

    func testInitDefaults() {
        let avatar = HABAvatar(size: .medium)
        XCTAssertEqual(avatar.size, .medium)
        XCTAssertEqual(avatar.shape, .circle)
        XCTAssertNil(avatar.image)
        XCTAssertNil(avatar.name)
    }

    func testInitWithName() {
        let avatar = HABAvatar(size: .large, name: "Christian Grise")
        XCTAssertEqual(avatar.name, "Christian Grise")
    }

    func testShapeMutation() {
        let avatar = HABAvatar(size: .medium)
        avatar.shape = .rounded
        XCTAssertEqual(avatar.shape, .rounded)
    }

    func testImageMutation() {
        let avatar = HABAvatar(size: .medium)
        let image = UIImage(systemName: "person.fill")
        avatar.image = image
        XCTAssertNotNil(avatar.image)
    }
}
