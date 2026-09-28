# HABDesignSystem

A reusable iOS design system: design tokens, a swappable theming layer, and
a library of UIKit components built on top of them. Built to be shared
across multiple apps (currently powering [Clarity](https://github.com/Haberdashery1234/Clarity))
instead of rebuilding the same buttons, cards, and inputs per project.

## Packages

- **`HABFoundation`** — the tokens: colors, typography, spacing, radius,
  shadow and motion, plus the `HABTheme` protocol, `HABThemeManager` and
  `HABThemeTrait`. Ships four themes (`HABDefaultTheme`, `HABLightTheme`,
  `HABDarkTheme`, `HABAppleTheme`), runtime-swappable via
  `HABThemeManager.shared.theme` (see [Theming](#theming)). Token types currently use
  UIKit types (`UIColor`, `UIFont`); a platform-neutral layer is planned
  alongside `HABSwiftUI`.
- **`HABUIKit`** — UIKit components built on `HABFoundation`: buttons
  (`HABButton`, `HABCardButton`), containers (`HABCard`, `HABDivider`),
  display (`HABAvatar`, `HABBadge`, `HABLabel`, `HABTag`), feedback
  (`HABBanner`, `HABEmptyState`, `HABLoadingView`, `HABToast`), inputs
  (`HABTextField`, `HABTextView`), navigation
  (`HABNavigationController`, `HABTabBarController`), selection
  (`HABSegmentedControl`, `HABToggle`), plus themed base view controllers
  (`HABBaseViewController`, `HABBaseTableViewController`,
  `HABBaseCollectionViewController`) that subclasses get theming from for
  free.

A `HABSwiftUI` target is planned but not implemented yet.

## Theming

```swift
HABThemeManager.shared.theme = HABDarkTheme()
```

- **Colors update themselves.** `UIColor.habPrimary`, `.habSurface` and the
  rest are dynamic colors. When the theme changes, `HABThemeManager` bumps
  `HABThemeTrait` on every window scene and UIKit re-resolves them wherever
  they're used, including colors your own views assigned.
- **Everything else is notified.** Fonts, `CGColor`s (layer borders and
  shadows) and radius/shadow tokens are re-applied when
  `HABThemeManager.themeDidChangeNotification` fires. HAB components and
  `HABBaseViewController` subclasses handle this for you. Override
  `themeDidChange()` for your own layer colors and fonts.
- **Custom themes** conform to `HABTheme` and provide `colors` and
  `typography`. `radius`, `shadows` and `motion` are optional and default to
  the library values. Store tokens with `let` so they're built once.
- **Threading:** the theme can be read and set from any thread. Trait
  updates and notifications always happen on the main thread.

```swift
struct ClarityTheme: HABTheme {
    let name = "Clarity"
    let colors: HABColorTokens = {
        var tokens = HABColorTokens()
        tokens.primary = UIColor(named: "ClarityTeal")!
        return tokens
    }()
    let typography = HABTypographyTokens()
    let radius = HABRadiusTokens(md: 14, lg: 20)   // optional
}
```

## Accessibility

- **Contrast:** `HABLightTheme` and `HABDarkTheme` meet WCAG AA for every
  pairing the components draw: 4.5:1 for text, including semantic text on its
  own tint, and 3:1 for input outlines. `HABThemeContrastTests` enforces this.
  `HABAppleTheme` mirrors Apple's system colors as-is, so it follows Apple's
  own contrast.
- **Touch targets:** interactive elements accept touches across at least
  44×44pt, even when they're drawn smaller.
- **Dynamic Type:** all component text scales live with the user's text size.
- **Reduce Motion:** movement is swapped for fades
  (`HABAnimation.prefersReducedMotion`).
- **VoiceOver:** statuses are announced by name ("Error", "Warning"), not just
  by color, and built-in strings are localized via the package's String Catalog.

## Distribution

- **Swift Package Manager** — add this repo as a package dependency.
- **`.xcframework`** — run `Scripts/build-xcframework.sh` for apps that
  need a binary framework instead.

## Requirements

- iOS 26+ / Mac Catalyst 26+
- Swift 6.2 tools; library targets build in Swift 6 language mode

## Sample app

`Sample/SAHABDesignSystem` is a small UIKit app exercising the
component library end-to-end — see
`Sample/SAHABDesignSystem/Resources/SAAnimatedLoading.gif` for a
quick look at `HABLoadingView` in action.

![HABLoadingView sample](Sample/SAHABDesignSystem/Resources/SAAnimatedLoading.gif)

## Getting started

```swift
// Package.swift
.package(url: "https://github.com/Haberdashery1234/HABDesignSystem.git", from: "0.1.0"),
```

```swift
import HABUIKit   // also brings in HABFoundation

let button = HABButton()
HABThemeManager.shared.theme = HABDarkTheme()
```

## Testing

`HABUIKitTests` covers the `HABUIKit` target.

```bash
swift test
```

## Status

Pre-1.0 (`0.x`): actively developed alongside Clarity, its first real
consumer. Minor versions may include breaking API changes until 1.0.

## License

MIT — see [LICENSE](LICENSE).
