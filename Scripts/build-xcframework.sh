#!/bin/bash
#
# build-xcframework.sh
#
# Builds HABUIKit.xcframework containing slices for:
#   • iOS device        (arm64)
#   • iOS Simulator     (arm64 + x86_64)
#   • macOS             (Mac Catalyst, arm64 + x86_64)
#
# Usage (run from the project root):
#   chmod +x Scripts/build-xcframework.sh
#   ./Scripts/build-xcframework.sh
#
# Output:
#   build/HABUIKit.xcframework
#
# Requirements:
#   • Xcode command-line tools
#   • xcpretty (optional, for readable output): gem install xcpretty
#

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────

PROJECT="HABUIKit.xcodeproj"
SCHEME="HABUIKit"
CONFIGURATION="Release"
BUILD_DIR="build"
DERIVED_DATA="$BUILD_DIR/DerivedData"
XCFRAMEWORK_OUTPUT="$BUILD_DIR/HABUIKit.xcframework"

# Common xcodebuild flags passed to every archive step.
# SKIP_INSTALL=NO  — places the framework in the archive's Products/ folder.
#                    This matches the project setting; passed explicitly for clarity.
# BUILD_LIBRARY_FOR_DISTRIBUTION=YES — emits .swiftinterface files so the
#                    binary framework is usable across different Swift versions.
#                    Also matches the project setting; explicit for documentation.
COMMON_FLAGS=(
    -project "$PROJECT"
    -scheme "$SCHEME"
    -configuration "$CONFIGURATION"
    -derivedDataPath "$DERIVED_DATA"
    SKIP_INSTALL=NO
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
)

# Use xcpretty for cleaner output if available, otherwise raw xcodebuild logs.
if command -v xcpretty &> /dev/null; then
    FORMATTER=(xcpretty)
else
    FORMATTER=(cat)
fi

# ── Clean ─────────────────────────────────────────────────────────────────────

echo "▸ Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ── Archive: iOS device ───────────────────────────────────────────────────────

echo "▸ Archiving for iOS (device)..."
xcodebuild archive \
    "${COMMON_FLAGS[@]}" \
    -destination "generic/platform=iOS" \
    -archivePath "$BUILD_DIR/ios.xcarchive" \
    | "${FORMATTER[@]}"

# ── Archive: iOS Simulator ────────────────────────────────────────────────────

echo "▸ Archiving for iOS Simulator..."
xcodebuild archive \
    "${COMMON_FLAGS[@]}" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$BUILD_DIR/ios-sim.xcarchive" \
    | "${FORMATTER[@]}"

# ── Archive: macOS (Mac Catalyst) ─────────────────────────────────────────────

echo "▸ Archiving for macOS (Mac Catalyst)..."
xcodebuild archive \
    "${COMMON_FLAGS[@]}" \
    -destination "platform=macOS,variant=Mac Catalyst" \
    -archivePath "$BUILD_DIR/macos.xcarchive" \
    | "${FORMATTER[@]}"

# ── Create xcframework ────────────────────────────────────────────────────────

echo "▸ Creating xcframework..."
xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/ios.xcarchive/Products/Library/Frameworks/HABUIKit.framework" \
    -framework "$BUILD_DIR/ios-sim.xcarchive/Products/Library/Frameworks/HABUIKit.framework" \
    -framework "$BUILD_DIR/macos.xcarchive/Products/Library/Frameworks/HABUIKit.framework" \
    -output "$XCFRAMEWORK_OUTPUT"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "✅ Built: $XCFRAMEWORK_OUTPUT"
echo ""
echo "To distribute via binary SPM, zip the xcframework and host it:"
echo "  zip -r HABUIKit.xcframework.zip $XCFRAMEWORK_OUTPUT"
echo "  # Then update Package.swift to use .binaryTarget(name:url:checksum:)"
