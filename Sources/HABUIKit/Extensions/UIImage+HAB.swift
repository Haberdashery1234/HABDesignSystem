//
//  UIImage+HAB.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public extension UIImage {
    // MARK: - Tinting

    /// Returns a copy of the image rendered with the given tint color.
    func withHABTint(_ color: UIColor) -> UIImage {
        return withTintColor(color, renderingMode: .alwaysOriginal)
    }

    // MARK: - Resizing

    /// Returns the image resized to the given size.
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Returns the image resized to a square with the given side length.
    func resized(to side: CGFloat) -> UIImage {
        resized(to: CGSize(width: side, height: side))
    }

    // MARK: - Cropping

    /// Returns the image cropped to a circle.
    func circularCropped() -> UIImage {
        let side = min(size.width, size.height)
        let squareSize = CGSize(width: side, height: side)
        let origin = CGPoint(x: (size.width - side) / 2, y: (size.height - side) / 2)

        let renderer = UIGraphicsImageRenderer(size: squareSize)
        return renderer.image { _ in
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: squareSize)).addClip()
            self.draw(at: CGPoint(x: -origin.x, y: -origin.y))
        }
    }

    // MARK: - SF Symbols

    /// Creates an SF Symbol image configured with the given point size and weight.
    static func habSymbol(
        _ name: String,
        size: CGFloat = 20,
        weight: UIImage.SymbolWeight = .regular
    ) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        return UIImage(systemName: name, withConfiguration: config)
    }
}
