//
//  HABImageViewTests.swift
//  HABUIKitTests
//
//  Tests for HABImageView.
//

import XCTest
import HABUIKit

final class HABImageViewTests: XCTestCase {
    // MARK: - Helpers

    private func makeImage(color: UIColor = .red, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Init

    func testDefaultImageIsNil() {
        let view = HABImageView()
        XCTAssertNil(view.image)
    }

    func testInitWithImage() {
        let image = makeImage()
        let view = HABImageView(image: image)
        XCTAssertNotNil(view.image)
    }

    func testInitWithPlaceholderUsesPlaceholderWhenNoImage() {
        let placeholder = makeImage(color: .blue)
        let view = HABImageView(placeholder: placeholder)
        // No image set — placeholder should be displayed via the image getter
        XCTAssertNotNil(view.image)
    }

    func testInitWithBothImageAndPlaceholderPrefersImage() {
        let image = makeImage(color: .red)
        let placeholder = makeImage(color: .blue)
        let view = HABImageView(image: image, placeholder: placeholder)
        // The image property should return the real image, not the placeholder
        XCTAssertEqual(view.image, image)
    }

    // MARK: - Mutation

    func testImageMutation() {
        let view = HABImageView()
        let image = makeImage()
        view.image = image
        XCTAssertNotNil(view.image)
    }

    func testPlaceholderShownWhenImageClearedToNil() {
        let placeholder = makeImage(color: .blue)
        let view = HABImageView(image: makeImage(), placeholder: placeholder)
        view.image = nil
        // After clearing image, placeholder should take over
        XCTAssertNotNil(view.image)
    }

    func testPlaceholderMutation() {
        let view = HABImageView()
        view.placeholder = makeImage()
        XCTAssertNotNil(view.placeholder)
    }

    // MARK: - Content Mode

    func testDefaultContentMode() {
        let view = HABImageView()
        XCTAssertEqual(view.imageContentMode, .scaleAspectFill)
    }

    func testContentModeMutation() {
        let view = HABImageView()
        view.imageContentMode = .scaleAspectFit
        XCTAssertEqual(view.imageContentMode, .scaleAspectFit)
    }

    func testAllContentModes() {
        let view = HABImageView()
        for mode in [HABImageView.ImageContentMode.scaleAspectFill, .scaleAspectFit, .center] {
            view.imageContentMode = mode
            XCTAssertEqual(view.imageContentMode, mode)
        }
    }

    // MARK: - Corner Radius

    func testDefaultCornerRadius() {
        let view = HABImageView()
        XCTAssertEqual(view.cornerRadius, 0)
    }

    func testCornerRadiusMutation() {
        let view = HABImageView()
        view.cornerRadius = 12
        XCTAssertEqual(view.cornerRadius, 12)
        XCTAssertEqual(view.layer.cornerRadius, 12)
    }

    // MARK: - Theme

    func testThemeChangeDoesNotCrash() {
        _ = HABImageView()
        NotificationCenter.default.post(
            name: HABThemeManager.themeDidChangeNotification,
            object: HABThemeManager.shared
        )
    }
}
