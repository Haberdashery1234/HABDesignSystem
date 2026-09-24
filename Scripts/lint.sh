#!/bin/bash
#
# lint.sh
#
# Runs SwiftLint over the whole repo — the HABDesignSystem package (Sources,
# Tests) and the sample app — using .swiftlint.yml at the repo root.
#
# Used by:
#   • the sample app's "Swiftlint" build phase (Xcode shows results inline)
#   • CI (.github/workflows/ios-ci.yml)
#   • you, from the terminal:  ./Scripts/lint.sh   or   ./Scripts/lint.sh --fix
#
# Extra arguments are passed through to `swiftlint`, e.g. --strict.

set -euo pipefail

# Xcode build phases don't inherit your shell PATH, so add Homebrew's locations.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

cd "$(dirname "$0")/.."

if ! command -v swiftlint &> /dev/null; then
    echo "warning: SwiftLint not installed. Install with: brew install swiftlint"
    exit 0
fi

if [ "${1:-}" = "--fix" ]; then
    shift
    swiftlint --fix "$@"
fi

swiftlint lint "$@"
