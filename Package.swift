// swift-tools-version: 6.2
//
// Package.swift
// HABDesignSystem
//
// Three frameworks, one package:
//   HABFoundation — design tokens, theme protocol, spacing, typography
//   HABUIKit      — UIKit components (depends on HABFoundation)
//   HABSwiftUI    — SwiftUI components (depends on HABFoundation)
//
// Distribution:
//   • Swift Package Manager — add this repo as a package dependency
//   • .xcframework          — run Scripts/build-xcframework.sh

import PackageDescription

// Library targets build in Swift 6 language mode (full data-race checking).
let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]

// Tests stay in Swift 5 mode for now so test classes don't all need @MainActor
// annotations at once; migrate them separately.
let testSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v5)
]

let package = Package(
    name: "HABDesignSystem",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macCatalyst(.v26)
    ],
    products: [
        .library(name: "HABFoundation", targets: ["HABFoundation"]),
        .library(name: "HABUIKit",      targets: ["HABUIKit"]),
    ],
    targets: [
        // MARK: - HABFoundation
        // Design tokens (color, typography, spacing, radius, shadow, motion), the theme
        // protocol, theme manager and theme trait.
        // No dependency on HABUIKit or HABSwiftUI.
        .target(
            name: "HABFoundation",
            swiftSettings: swiftSettings
        ),

        // MARK: - HABUIKit
        // UIKit components. Depends on HABFoundation for tokens and theming.
        .target(
            name: "HABUIKit",
            dependencies: ["HABFoundation"],
            resources: [
                // Localizable.xcstrings: user-facing and VoiceOver strings.
                .process("Resources")
            ],
            swiftSettings: swiftSettings
        ),

        // MARK: - Tests
        .testTarget(
            name: "HABUIKitTests",
            dependencies: ["HABUIKit"],
            swiftSettings: testSwiftSettings
        )
    ]
)
