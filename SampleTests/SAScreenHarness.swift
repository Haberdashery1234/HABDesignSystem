//
//  SAScreenHarness.swift
//  SAHABDesignSystemTests
//
//  Puts sample screens in a real window and navigation controller, and works
//  their settings controls the way a person tapping through them would.
//

import UIKit
import XCTest
import HABUIKit
@testable import SAHABDesignSystem

/// A window with an `SANavigationController`, like the one the app builds at launch.
@MainActor
final class SAScreenHarness {
    let window: UIWindow
    let navigationController: SANavigationController

    init(root: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError("SAScreenHarness requires a connected UIWindowScene to run tests")
        }
        window = UIWindow(windowScene: scene)
        navigationController = SANavigationController(rootViewController: root)
        window.rootViewController = navigationController
        window.isHidden = false
        layout()
    }

    /// The screen currently on top of the navigation stack.
    var topViewController: UIViewController? {
        navigationController.topViewController
    }

    func push(_ viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: false)
        viewController.loadViewIfNeeded()
        layout()
    }

    /// Lets an animated push or pop finish. UIKit runs the transition on the main run
    /// loop, so turn it until no transition is in progress (or a second has passed).
    func waitForTransitions() {
        let deadline = Date().addingTimeInterval(1)
        while navigationController.transitionCoordinator != nil, Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        layout()
    }

    func popToRoot() {
        navigationController.popToRootViewController(animated: false)
        layout()
    }

    func layout() {
        window.layoutIfNeeded()
    }

    /// Hide the window so it doesn't linger over the host app between tests.
    func tearDown() {
        window.isHidden = true
        window.rootViewController = nil
    }
}

/// Drives every control in a view hierarchy through its values.
@MainActor
enum SAControlExerciser {
    /// Works each control, then does it again to reach controls the first pass revealed
    /// (some demos rebuild their settings when a segment changes).
    static func exerciseControls(in root: UIView, passes: Int = 2) {
        for _ in 0..<passes {
            for control in root.saDescendants(of: UIControl.self) where shouldExercise(control, in: root) {
                exercise(control)
            }
            root.layoutIfNeeded()
        }
    }

    /// Only the controls a screen adds itself. Controls nested inside another control are
    /// that control's private parts (the buttons inside a compact `UIDatePicker` open a
    /// calendar popup and throw when it can't be presented), so they're skipped. The one
    /// exception is `HABChipGroup`, whose chips are the way you use it.
    private static func shouldExercise(_ control: UIControl, in root: UIView) -> Bool {
        if control is UIDatePicker { return false }
        var ancestor = control.superview
        while let view = ancestor, view !== root {
            if view is UIControl, !(view is HABChipGroup) { return false }
            ancestor = view.superview
        }
        return true
    }

    static func exercise(_ control: UIControl) {
        guard control.isEnabled, !control.isHidden else { return }
        switch control {
            case let toggle as UISwitch:
                for _ in 0..<2 {
                    toggle.setOn(!toggle.isOn, animated: false)
                    toggle.sendActions(for: .valueChanged)
                }
            case let segmented as UISegmentedControl:
                let original = segmented.selectedSegmentIndex
                for index in 0..<segmented.numberOfSegments {
                    segmented.selectedSegmentIndex = index
                    segmented.sendActions(for: .valueChanged)
                }
                if original >= 0 {
                    segmented.selectedSegmentIndex = original
                    segmented.sendActions(for: .valueChanged)
                }
            case let stepper as UIStepper:
                let original = stepper.value
                for value in [stepper.maximumValue, stepper.minimumValue, original] {
                    stepper.value = value
                    stepper.sendActions(for: .valueChanged)
                }
            case let menu as HABMenuButton:
                // A menu opens through a context menu interaction, not target-action;
                // call its selection handler for each option instead.
                let original = menu.selectedIndex
                for index in menu.options.indices {
                    menu.selectedIndex = index
                    menu.onSelectionChanged?(index)
                }
                if let original {
                    menu.selectedIndex = original
                    menu.onSelectionChanged?(original)
                }
            case let stepper as HABStepper:
                stepper.accessibilityIncrement()
                stepper.accessibilityDecrement()
            case let field as UITextField:
                field.text = "Sample text"
                field.sendActions(for: .editingChanged)
            case let button as UIButton:
                button.sendActions(for: .touchDown)
                button.sendActions(for: .touchUpInside)
            default:
                break
        }
    }
}

extension UIView {
    /// Every descendant of type `T`, depth first.
    func saDescendants<T: UIView>(of type: T.Type) -> [T] {
        subviews.flatMap { sub -> [T] in
            ((sub as? T).map { [$0] } ?? []) + sub.saDescendants(of: type)
        }
    }
}
