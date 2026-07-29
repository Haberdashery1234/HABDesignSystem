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

let swiftSettings: [SwiftSetting] = [
    // Swift 5 semantics avoids Sendable annotation churn in UIKit-heavy code.
    .swiftLanguageMode(.v5)
]

let package = Package(
    name: "HABDesignSystem",
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
        // Design tokens, theme protocol, theme manager, spacing, typography.
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
            swiftSettings: swiftSettings
        ),

        // MARK: - Tests
        .testTarget(
            name: "HABUIKitTests",
            dependencies: ["HABUIKit"],
            swiftSettings: swiftSettings
        )
    ]
)
