//
//  UIView+TestSearch.swift
//  HABUIKitTests
//
//  Finds subviews by type, for tests that check a component's internal layout.
//

import UIKit

extension UIView {
    /// Every descendant of type `T`, depth first.
    func descendants<T: UIView>(of type: T.Type) -> [T] {
        subviews.flatMap { sub -> [T] in
            ((sub as? T).map { [$0] } ?? []) + sub.descendants(of: type)
        }
    }
}
