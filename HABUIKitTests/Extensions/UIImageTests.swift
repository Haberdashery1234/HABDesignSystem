//
//  UIImageTests.swift
//  HABUIKitTests
//
//  Tests for UIImage+HAB extensions.
//

import XCTest
import HABUIKit

final class UIImageTests: XCTestCase {
    // MARK: - Helpers

    private func makeImage(
        size: CGSize = CGSize(width: 100, height: 60)
    ) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - withHABTint

    func testWithHABTintReturnsImage() {
        let image = makeImage()
        let tinted = image.withHABTint(.blue)
        XCTAssertNotNil(tinted)
    }

    func testWithHABTintPreservesSize() {
        let image = makeImage(size: CGSize(width: 40, height: 40))
        let tinted = image.withHABTint(.green)
        XCTAssertEqual(tinted.size, image.size)
    }

    // MARK: - resized(to:CGSize)

    func testResizedToSizeProducesCorrectSize() {
        let image = makeImage()
        let target = CGSize(width: 50, height: 50)
        let resized = image.resized(to: target)
        XCTAssertEqual(resized.size.width, target.width, accuracy: 1)
        XCTAssertEqual(resized.size.height, target.height, accuracy: 1)
    }

    func testResizedToSizeNonSquare() {
        let image = makeImage()
        let target = CGSize(width: 200, height: 80)
        let resized = image.resized(to: target)
        XCTAssertEqual(resized.size.width, target.width, accuracy: 1)
        XCTAssertEqual(resized.size.height, target.height, accuracy: 1)
    }

    // MARK: - resized(to:CGFloat)

    func testResizedToSideProducesSquare() {
        let image = makeImage()
        let resized = image.resized(to: 32)
        XCTAssertEqual(resized.size.width, 32, accuracy: 1)
        XCTAssertEqual(resized.size.height, 32, accuracy: 1)
    }

    // MARK: - circularCropped

    func testCircularCroppedOutputIsSquare() {
        let image = makeImage(size: CGSize(width: 100, height: 60))
        let cropped = image.circularCropped()
        XCTAssertEqual(cropped.size.width, cropped.size.height)
    }

    func testCircularCroppedSideIsMinDimension() {
        let image = makeImage(size: CGSize(width: 100, height: 60))
        let cropped = image.circularCropped()
        XCTAssertEqual(cropped.size.width, 60, accuracy: 1)
    }

    func testCircularCroppedSquareImagePreservesSize() {
        let image = makeImage(size: CGSize(width: 80, height: 80))
        let cropped = image.circularCropped()
        XCTAssertEqual(cropped.size.width, 80, accuracy: 1)
        XCTAssertEqual(cropped.size.height, 80, accuracy: 1)
    }

    // MARK: - habSymbol

    func testHabSymbolReturnsImageForValidName() {
        let image = UIImage.habSymbol("star")
        XCTAssertNotNil(image)
    }

    func testHabSymbolReturnsNilForInvalidName() {
        let image = UIImage.habSymbol("this.symbol.does.not.exist.xyz")
        XCTAssertNil(image)
    }

    func testHabSymbolCustomSize() {
        let image = UIImage.habSymbol("star", size: 40)
        XCTAssertNotNil(image)
    }

    func testHabSymbolCustomWeight() {
        let image = UIImage.habSymbol("star", weight: .bold)
        XCTAssertNotNil(image)
    }
}
