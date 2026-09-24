# HABDesignSystem

A reusable iOS design system: design tokens, a swappable theming layer, and
a library of UIKit components built on top of them. Built to be shared
across multiple apps (currently powering [Clarity](https://github.com/Haberdashery1234/Clarity))
instead of rebuilding the same buttons, cards, and inputs per project.

## Packages

- **`HABFoundation`** — the tokens: colors, spacing, radius, typography,
  plus the `HABTheme` protocol and `HABThemeManager`. Ships four themes
  (`HABDefaultTheme`, `HABLightTheme`, `HABDarkTheme`, `HABAppleTheme`),
  runtime-swappable via `HABThemeManager.shared.theme` — components
  observe theme changes automatically via `NotificationCenter`, so
  switching themes updates the whole UI live. Token types currently use
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
- Swift 6.2 tools (targets build in Swift 5 language mode to avoid
  Sendable churn in the UIKit-heavy component code)

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
import HABFoundation
import HABUIKit

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
