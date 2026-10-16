//
//  HABSwipeAction.swift
//  HABUIKit
//

import UIKit
import HABFoundation

/// Color roles for table view swipe actions.
///
/// ```swift
/// override func tableView(
///     _ tableView: UITableView,
///     trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
/// ) -> UISwipeActionsConfiguration? {
///     let taken = UIContextualAction.hab(.success, title: "Taken", image: UIImage(systemName: "checkmark")) { _, _, done in
///         self.markTaken(at: indexPath)
///         done(true)
///     }
///     let skip = UIContextualAction.hab(.warning, title: "Skip", image: UIImage(systemName: "forward")) { _, _, done in
///         self.skip(at: indexPath)
///         done(true)
///     }
///     return UISwipeActionsConfiguration(actions: [taken, skip])
/// }
/// ```
///
/// Swipe actions also appear in VoiceOver's Actions rotor, named by their titles, so give
/// every action a title even when it has an icon.
///
/// UIKit always draws swipe action titles and icons in white. The colors come from the
/// theme's semantic tokens; with themes whose warning or success colors are light, white
/// text on them can fall below 4.5:1 contrast, so check custom themes on device.
public enum HABSwipeActionStyle: CaseIterable {
    /// Positive actions: "Taken", "Done", "Mark as read".
    case success
    /// Actions that need attention but aren't destructive: "Skip", "Snooze".
    case warning
    /// Actions that remove or undo something: "Delete", "Remove".
    case destructive
    /// Secondary actions with no particular weight: "Edit", "More".
    case neutral

    /// The background color for this style, from the active theme.
    public var backgroundColor: UIColor {
        switch self {
            case .success:
                return .habSuccess
            case .warning:
                return .habWarning
            case .destructive:
                return .habDestructive
            case .neutral:
                // Secondary text can be translucent (as in `HABAppleTheme`); flatten it onto
                // the background so the action is a solid gray.
                return HABDerivedColors.swipeNeutral
        }
    }
}

public extension UIContextualAction {
    /// Creates a swipe action in one of the HAB color styles.
    ///
    /// - Parameters:
    ///   - style: The color role.
    ///   - title: The action's name. VoiceOver uses it in the Actions rotor.
    ///   - image: An optional icon, usually an SF Symbol.
    ///   - removesRow: Pass `true` when completing the action deletes the row. UIKit then
    ///     animates the row away as the action finishes. Defaults to `false`.
    ///   - handler: Runs when the user taps or fully swipes the action. Call its
    ///     completion with `true` once the action is done.
    static func hab(
        _ style: HABSwipeActionStyle,
        title: String,
        image: UIImage? = nil,
        removesRow: Bool = false,
        handler: @escaping UIContextualAction.Handler
    ) -> UIContextualAction {
        let action = UIContextualAction(
            style: removesRow ? .destructive : .normal,
            title: title,
            handler: handler
        )
        action.backgroundColor = style.backgroundColor
        action.image = image
        return action
    }
}

extension HABDerivedColors {
    nonisolated(unsafe) static let swipeNeutral = UIColor.habBlend(.habForegroundSecondary, over: .habBackground, fraction: 1)
}
