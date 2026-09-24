//
//  HABMinimumHitArea.swift
//  HABUIKit
//
//  Apple's HIG asks for touch targets of at least 44×44pt. These helpers
//  grow a control's *touch* area to that minimum, centered on it, without
//  changing how large it looks.
//

import UIKit

enum HABHitArea {
    /// Minimum touch target edge length, in points.
    static let minimumSize: CGFloat = 44
}

extension CGRect {
    /// This rect grown (never shrunk) to at least `size` × `size`, keeping its center.
    func expandedToMinimum(_ size: CGFloat = HABHitArea.minimumSize) -> CGRect {
        insetBy(dx: min(0, (width - size) / 2), dy: min(0, (height - size) / 2))
    }
}

/// A `UIButton` that accepts touches across at least 44×44pt, even when it's drawn smaller.
///
/// Note: touches only reach a subview if its superview also accepts them at that point.
/// Containers smaller than 44pt (like `HABTag`) must extend their own `point(inside:with:)`.
final class HABMinimumHitAreaButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.expandedToMinimum().contains(point)
    }
}
