#!/bin/bash
#
# build-xcframework.sh
#
# Builds xcframeworks from the HABDesignSystem SPM package:
#   • HABFoundation.xcframework — design tokens, theme system
#   • HABUIKit.xcframework      — UIKit components
#
# (Add HABSwiftUI to FRAMEWORKS below once that target exists in Package.swift.)
#
# Each xcframework contains slices for:
#   • iOS device        (arm64)
#   • iOS Simulator     (arm64 + x86_64)
#   • macOS             (Mac Catalyst, arm64 + x86_64)
#
# Usage (run from the project root):
#   chmod +x Scripts/build-xcframework.sh
#   ./Scripts/build-xcframework.sh
#
# Output:
#   build/HABFoundation.xcframework
#   build/HABUIKit.xcframework
#

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────

CONFIGURATION="Release"
BUILD_DIR="build"
DERIVED_DATA="$BUILD_DIR/DerivedData"

# Frameworks to build, in dependency order.
FRAMEWORKS=("HABFoundation" "HABUIKit")

# Common xcodebuild flags.
COMMON_FLAGS=(
    -configuration "$CONFIGURATION"
    -derivedDataPath "$DERIVED_DATA"
    SKIP_INSTALL=NO
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
)

if command -v xcpretty &> /dev/null; then
    FORMATTER=(xcpretty)
else
    FORMATTER=(cat)
fi

# ── Clean ─────────────────────────────────────────────────────────────────────

echo "▸ Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ── Build each framework ──────────────────────────────────────────────────────

for SCHEME in "${FRAMEWORKS[@]}"; do
    echo ""
    echo "▸ Building $SCHEME..."

    xcodebuild archive \
        "${COMMON_FLAGS[@]}" \
        -scheme "$SCHEME" \
        -destination "generic/platform=iOS" \
        -archivePath "$BUILD_DIR/$SCHEME-ios.xcarchive" \
        | "${FORMATTER[@]}"

    xcodebuild archive \
        "${COMMON_FLAGS[@]}" \
        -scheme "$SCHEME" \
        -destination "generic/platform=iOS Simulator" \
        -archivePath "$BUILD_DIR/$SCHEME-ios-sim.xcarchive" \
        | "${FORMATTER[@]}"

    xcodebuild archive \
        "${COMMON_FLAGS[@]}" \
        -scheme "$SCHEME" \
        -destination "platform=macOS,variant=Mac Catalyst" \
        -archivePath "$BUILD_DIR/$SCHEME-macos.xcarchive" \
        | "${FORMATTER[@]}"

    for ARCHIVE in ios ios-sim macos; do
        FRAMEWORK_PATH="$BUILD_DIR/$SCHEME-$ARCHIVE.xcarchive/Products/Library/Frameworks/$SCHEME.framework"
        if [ ! -d "$FRAMEWORK_PATH" ]; then
            echo "error: $FRAMEWORK_PATH not found." >&2
            echo "       SPM library products with automatic linkage may archive as static" >&2
            echo "       objects rather than .framework bundles. If so, declare the product" >&2
            echo "       with 'type: .dynamic' in Package.swift for binary distribution." >&2
            exit 1
        fi
    done

    xcodebuild -create-xcframework \
        -framework "$BUILD_DIR/$SCHEME-ios.xcarchive/Products/Library/Frameworks/$SCHEME.framework" \
        -framework "$BUILD_DIR/$SCHEME-ios-sim.xcarchive/Products/Library/Frameworks/$SCHEME.framework" \
        -framework "$BUILD_DIR/$SCHEME-macos.xcarchive/Products/Library/Frameworks/$SCHEME.framework" \
        -output "$BUILD_DIR/$SCHEME.xcframework"

    echo "  ✅ $BUILD_DIR/$SCHEME.xcframework"
done

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "✅ All frameworks built in $BUILD_DIR/"
echo ""
echo "To distribute via binary SPM, zip each xcframework:"
echo "  cd $BUILD_DIR"
echo "  zip -r HABFoundation.xcframework.zip HABFoundation.xcframework"
echo "  zip -r HABUIKit.xcframework.zip HABUIKit.xcframework"
