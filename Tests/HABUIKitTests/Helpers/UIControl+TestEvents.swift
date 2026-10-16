//
//  UIControl+TestEvents.swift
//  HABUIKitTests
//
//  Fires a control's target-actions directly. `sendActions(for:)` routes through
//  `UIApplication.shared`, which unit tests can't rely on having.
//

import UIKit

extension UIControl {
    /// Calls every action registered for `event`, as if the user triggered it.
    func simulate(_ event: UIControl.Event) {
        for target in allTargets {
            guard let object = target.base as? NSObject,
                  let actions = actions(forTarget: object, forControlEvent: event) else { continue }
            for action in actions {
                let selector = Selector(action)
                if action.hasSuffix(":") {
                    object.perform(selector, with: self)
                } else {
                    object.perform(selector)
                }
            }
        }
    }
}
