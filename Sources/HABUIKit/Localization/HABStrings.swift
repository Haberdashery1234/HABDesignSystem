//
//  HABStrings.swift
//  HABUIKit
//
//  Every user-facing and VoiceOver string HABUIKit produces, resolved from
//  the package's own Localizable.xcstrings (Bundle.module), so apps can't
//  accidentally shadow them and translations ship with the library.
//
//  The string keys are written as literals here, in one place. String
//  catalog symbol generation targets Xcode app targets; this keeps the
//  package building under plain SwiftPM too.
//

import Foundation

enum HABStrings {
    /// "Loading" — busy button value and loading indicator label.
    static var loading: String {
        String(localized: "Loading", bundle: .module, comment: "VoiceOver text for a loading indicator, or a button that's busy.")
    }

    /// "Avatar" — label for an avatar with no name.
    static var avatar: String {
        String(localized: "Avatar", bundle: .module, comment: "VoiceOver label for an avatar with no name.")
    }

    /// "3 notifications" (pluralized) — badge label.
    static func notifications(_ count: Int) -> String {
        String(localized: "\(count) notifications", bundle: .module, comment: "VoiceOver label for a notification count badge.")
    }

    /// Localized percentage for progress, e.g. "50%" (VoiceOver reads "50 percent").
    static func percent(_ fraction: Float) -> String {
        Double(fraction).formatted(.percent.precision(.fractionLength(0)))
    }

    // MARK: Status names (banners, toasts)

    static var information: String {
        String(localized: .information)
    }

    static var success: String {
        String(localized: .success)
    }

    static var warning: String {
        String(localized: .warning)
    }

    static var error: String {
        String(localized: .error)
    }

    /// "Error: Couldn't save" — a status name followed by a message.
    static func status(_ status: String, message: String) -> String {
        "\(status): \(message)"
    }
}
