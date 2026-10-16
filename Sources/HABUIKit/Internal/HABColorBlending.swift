//
//  HABColorBlending.swift
//  HABUIKit
//
//  Opaque colors made by mixing two theme colors, for states the tokens don't
//  cover directly (a pressed row, a solid neutral swipe action).
//

import UIKit
import HABFoundation

/// RGBA color components in the sRGB color space.
struct RGBAComponents {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

extension UIColor {
    /// A dynamic, opaque color: `overlay` laid over `base` at `fraction` (0...1).
    ///
    /// Both colors are resolved for the requesting traits each time, so the result
    /// follows the active theme and light/dark appearance like the `hab*` colors do.
    static func habBlend(_ overlay: UIColor, over base: UIColor, fraction: CGFloat) -> UIColor {
        UIColor { traits in
            let bottom = base.resolvedColor(with: traits).habRGBA
            let top = overlay.resolvedColor(with: traits).habRGBA
            // Treat a translucent overlay (e.g. `.secondaryLabel`) as its own alpha × fraction.
            let amount = max(0, min(1, fraction)) * top.alpha
            // The base is treated as opaque: surfaces and backgrounds are.
            return UIColor(
                red: bottom.red + (top.red - bottom.red) * amount,
                green: bottom.green + (top.green - bottom.green) * amount,
                blue: bottom.blue + (top.blue - bottom.blue) * amount,
                alpha: 1
            )
        }
    }

    /// Background for a pressed or selected row on a surface.
    static var habSurfaceHighlighted: UIColor { HABDerivedColors.surfaceHighlighted }

    /// Components in the sRGB space. Falls back to white-based conversion for grayscale colors.
    var habRGBA: RGBAComponents {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
        }
        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return RGBAComponents(red: white, green: white, blue: white, alpha: alpha)
        }
        return RGBAComponents(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

/// Derived dynamic colors, created once (see `HABThemedColors`).
enum HABDerivedColors {
    nonisolated(unsafe) static let surfaceHighlighted = UIColor.habBlend(.habForeground, over: .habSurface, fraction: 0.1)
}
