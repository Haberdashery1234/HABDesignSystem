// swift-tools-version: 6.0
//
// Package.swift
// HABUIKit
//
// Supports three distribution paths:
//   • Swift Package Manager — add this repo as a package dependency
//   • .framework            — build the HABUIKit scheme in Xcode
//   • .xcframework          — run Scripts/build-xcframework.sh
//

import PackageDescription

let package = Package(
    name: "HABUIKit",
    platforms: [
        .iOS(.v26),
        .macCatalyst(.v26)
    ],
    products: [
        .library(
            name: "HABUIKit",
            targets: ["HABUIKit"]
        )
    ],
    targets: [
        // Sources live at Sources/HABUIKit/ — the default SPM path, no override needed.
        // SPM picks up all .swift files and the HABUIKit.docc catalog automatically.
        .target(
            name: "HABUIKit",
            swiftSettings: [
                // Keep Swift 5 semantics so UIKit-heavy code compiles cleanly
                // under a Swift 6 toolchain without Sendable annotation churn.
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "HABUIKitTests",
            dependencies: ["HABUIKit"],
            // Tests remain at HABUIKitTests/ (alongside the Xcode project) rather
            // than the SPM default of Tests/HABUIKitTests/, so the path is explicit.
            path: "HABUIKitTests",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
