//
//  UIView+HAB.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

public extension UIView {
    // MARK: - Subview Helpers

    /// Adds multiple subviews in one call.
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    // MARK: - Layout Helpers

    /// Pins all four edges to the superview, with optional insets.
    func pinToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Pins to superview's safe area layout guide.
    func pinToSuperviewSafeArea(insets: UIEdgeInsets = .zero) {
        guard let superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Centers in superview.
    func centerInSuperview(offset: CGPoint = .zero) {
        guard let superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: offset.x),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: offset.y)
        ])
    }

    /// Constrains width and/or height to fixed constants.
    func constrainSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    // MARK: - Shadow

    /// Applies an HABShadowStyle to this view's layer.
    func applyShadow(_ shadow: HABShadowStyle) {
        shadow.apply(to: layer)
    }

    // MARK: - Corner Radius

    /// Rounds specific corners with a given radius using a CAShapeLayer mask.
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    // MARK: - Visibility

    /// Fades the view in from alpha 0 to 1.
    func fadeIn(duration: TimeInterval = HABAnimation.Duration.normal) {
        alpha = 0
        UIView.animate(withDuration: duration) { self.alpha = 1 }
    }

    /// Fades the view out to alpha 0, then hides it.
    func fadeOut(duration: TimeInterval = HABAnimation.Duration.normal, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 0 },
            completion: { _ in
                self.isHidden = true
                completion?()
            }
        )
    }
}
