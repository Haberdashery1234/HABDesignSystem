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
  switching themes updates the whole UI live. No UIKit/SwiftUI dependency.
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

## Distribution

- **Swift Package Manager** — add this repo as a package dependency.
- **`.xcframework`** — run `Scripts/build-xcframework.sh` for apps that
  need a binary framework instead.

## Requirements

- iOS 26+ / Mac Catalyst 26+
- Swift 6.2 tools (targets build in Swift 5 language mode to avoid
  Sendable churn in the UIKit-heavy component code)

## Sample app

`Sample/HABDesignSystemSample` is a small UIKit app exercising the
component library end-to-end — see
`Sample/HABDesignSystemSample/Resources/SampleAnimatedLoading.gif` for a
quick look at `HABLoadingView` in action.

![HABLoadingView sample](Sample/HABDesignSystemSample/Resources/SampleAnimatedLoading.gif)

## Getting started

```swift
// Package.swift
.package(url: "https://github.com/Haberdashery1234/HABDesignSystem.git", from: "1.0.0"),
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

Actively developed alongside Clarity, its first real consumer.
