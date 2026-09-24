//
//  HABAnimation.swift
//  HABFoundation
//
//  Created by Christian Grise on 6/29/26.
//

#if canImport(UIKit)
import UIKit

// MARK: - HABAnimation

/// Animation constants.
///
/// `HABAnimation.Duration` and `HABAnimation.Spring` are the *default* motion values.
/// Components read motion from the active theme (`HABTheme.motion`), which starts from
/// these defaults and can be overridden per theme. Use `HABAnimation.Curve` for easing.
///
/// ```swift
/// UIView.animate(withDuration: HABThemeManager.shared.theme.motion.normal,
///                delay: 0,
///                options: HABAnimation.Curve.easeOut.options) {
///     view.alpha = 1
/// }
/// ```
public enum HABAnimation {
    // MARK: - Accessibility

    /// `true` when the user has turned on Reduce Motion (Settings › Accessibility › Motion).
    ///
    /// When it's on, replace movement — slides, scaling, springs — with a fade or no
    /// animation. Fades and progress indicators are fine to keep.
    @MainActor
    public static var prefersReducedMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    // MARK: - Duration

    /// Default duration values. Themes can override these via `HABMotionTokens`.
    public enum Duration {
        /// 0s — immediate state change with no animation.
        public static let instant: TimeInterval = 0

        /// 0.15s — micro-interactions such as button presses and toggles.
        public static let fast: TimeInterval = 0.15

        /// 0.25s — standard transitions such as pushes and fades.
        public static let normal: TimeInterval = 0.25

        /// 0.4s — deliberate, attention-drawing animations.
        public static let slow: TimeInterval = 0.4

        /// 0.6s — complex multi-step or large-scale sequences.
        public static let verySlow: TimeInterval = 0.6
    }

    // MARK: - Curve

    /// Named easing curve presets compatible with `UIView.animate` and Core Animation.
    public struct HABAnimationCurve {
        /// `UIView.AnimationOptions` for use with `UIView.animate(withDuration:options:)`.
        public let options: UIView.AnimationOptions

        /// `CAMediaTimingFunction` for use with Core Animation.
        public let timingFunction: CAMediaTimingFunction

        private init(options: UIView.AnimationOptions, timingFunction: CAMediaTimingFunction) {
            self.options        = options
            self.timingFunction = timingFunction
        }

        // CAMediaTimingFunction isn't Sendable, but these presets are never mutated,
        // so sharing them across isolation domains is safe.

        /// Symmetric ease in/out. The default for most transitions.
        nonisolated(unsafe) public static let standard = HABAnimationCurve(
            options: .curveEaseInOut,
            timingFunction: .init(name: .easeInEaseOut)
        )

        /// Accelerates into the animation. Use for elements leaving the screen.
        nonisolated(unsafe) public static let easeIn = HABAnimationCurve(
            options: .curveEaseIn,
            timingFunction: .init(name: .easeIn)
        )

        /// Decelerates to rest. Use for elements arriving on screen.
        nonisolated(unsafe) public static let easeOut = HABAnimationCurve(
            options: .curveEaseOut,
            timingFunction: .init(name: .easeOut)
        )

        /// Constant speed throughout. Use for progress indicators and looping animations.
        nonisolated(unsafe) public static let linear = HABAnimationCurve(
            options: .curveLinear,
            timingFunction: .init(name: .linear)
        )
    }

    /// Easing curve presets.
    public enum Curve {
        /// Symmetric ease in/out. The default for most transitions.
        public static var standard: HABAnimationCurve { .standard }

        /// Accelerates into the animation. Use for elements leaving the screen.
        public static var easeIn: HABAnimationCurve { .easeIn }

        /// Decelerates to rest. Use for elements arriving on screen.
        public static var easeOut: HABAnimationCurve { .easeOut }

        /// Constant speed throughout. Use for progress indicators and looping animations.
        public static var linear: HABAnimationCurve { .linear }
    }

    // MARK: - Spring

    /// A spring animation preset for `UIView.animate(springDuration:bounce:)`.
    ///
    /// ```swift
    /// let spring = HABThemeManager.shared.theme.motion.gentleSpring
    /// UIView.animate(springDuration: spring.duration, bounce: spring.bounce) {
    ///     view.transform = .identity
    /// }
    /// ```
    public struct HABSpringPreset: Sendable, Equatable {
        /// Recommended duration for this spring preset.
        public let duration: TimeInterval

        /// Bounce amount. `0` is no bounce, `1` is very bouncy.
        public let bounce: CGFloat

        /// Creates a spring preset, e.g. for a custom theme's `HABMotionTokens`.
        public init(duration: TimeInterval, bounce: CGFloat) {
            self.duration = duration
            self.bounce   = bounce
        }

        /// Low bounce, settles quickly. Use for most UI interactions.
        public static let gentle = HABSpringPreset(duration: 0.35, bounce: 0.15)

        /// Higher bounce, more playful. Use for celebratory or game-like moments.
        public static let bouncy = HABSpringPreset(duration: 0.5, bounce: 0.4)
    }

    /// Default spring presets. Themes can override these via `HABMotionTokens`.
    public enum Spring {
        /// Low bounce, settles quickly. Use for most UI interactions.
        public static let gentle = HABSpringPreset.gentle

        /// Higher bounce, more playful. Use for celebratory or game-like moments.
        public static let bouncy = HABSpringPreset.bouncy
    }
}
#endif
