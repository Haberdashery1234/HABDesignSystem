//
//  HABAnimation.swift
//  HABUIKit
//
//  Created by Christian Grise on 6/29/26.
//

import UIKit

// MARK: - HABAnimation

/// Animation constants for HABUIKit.
///
/// Use `HABAnimation.Duration` for timing and `HABAnimation.Curve` for easing.
/// For spring animations, use `HABAnimation.Spring`.
///
/// ```swift
/// UIView.animate(withDuration: HABAnimation.Duration.normal,
///                delay: 0,
///                options: HABAnimation.Curve.easeOut.options) {
///     view.alpha = 1
/// }
/// ```
public enum HABAnimation {
    // MARK: - Duration

    /// Named duration constants for animations.
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

        /// Symmetric ease in/out. The default for most transitions.
        public static let standard = HABAnimationCurve(
            options: .curveEaseInOut,
            timingFunction: .init(name: .easeInEaseOut)
        )

        /// Accelerates into the animation. Use for elements leaving the screen.
        public static let easeIn = HABAnimationCurve(
            options: .curveEaseIn,
            timingFunction: .init(name: .easeIn)
        )

        /// Decelerates to rest. Use for elements arriving on screen.
        public static let easeOut = HABAnimationCurve(
            options: .curveEaseOut,
            timingFunction: .init(name: .easeOut)
        )

        /// Constant speed throughout. Use for progress indicators and looping animations.
        public static let linear = HABAnimationCurve(
            options: .curveLinear,
            timingFunction: .init(name: .linear)
        )
    }

    /// Easing curve presets.
    public enum Curve {
        /// Symmetric ease in/out. The default for most transitions.
        public static let standard = HABAnimationCurve.standard

        /// Accelerates into the animation. Use for elements leaving the screen.
        public static let easeIn   = HABAnimationCurve.easeIn

        /// Decelerates to rest. Use for elements arriving on screen.
        public static let easeOut  = HABAnimationCurve.easeOut

        /// Constant speed throughout. Use for progress indicators and looping animations.
        public static let linear   = HABAnimationCurve.linear
    }

    // MARK: - Spring

    /// Spring animation presets for use with `UIView.animate(springDuration:bounce:)`.
    ///
    /// ```swift
    /// UIView.animate(springDuration: HABAnimation.Duration.normal,
    ///                bounce: HABAnimation.Spring.gentle.bounce) {
    ///     view.transform = .identity
    /// }
    /// ```
    public struct HABSpringPreset {
        /// Recommended duration for this spring preset.
        public let duration: TimeInterval

        /// Bounce amount. `0` is no bounce, `1` is very bouncy.
        public let bounce: CGFloat

        private init(duration: TimeInterval, bounce: CGFloat) {
            self.duration = duration
            self.bounce   = bounce
        }

        /// Low bounce, settles quickly. Use for most UI interactions.
        public static let gentle = HABSpringPreset(duration: 0.35, bounce: 0.15)

        /// Higher bounce, more playful. Use for celebratory or game-like moments.
        public static let bouncy = HABSpringPreset(duration: 0.5, bounce: 0.4)
    }

    /// Spring animation presets.
    public enum Spring {
        /// Low bounce, settles quickly. Use for most UI interactions.
        public static let gentle = HABSpringPreset.gentle

        /// Higher bounce, more playful. Use for celebratory or game-like moments.
        public static let bouncy = HABSpringPreset.bouncy
    }
}
