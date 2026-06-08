#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Build and install Converlax on the paired iPad.

Usage:
  scripts/build-install-ipad.sh [--launch]

Environment overrides:
  PROJECT              Xcode project path. Default: Converlax.xcodeproj
  SCHEME               Xcode scheme. Default: Converlax
  CONFIGURATION        Build configuration. Default: Debug
  XCODE_DEVICE_ID      Device id used by xcodebuild destination.
  DEVICETL_DEVICE_ID   Device id used by xcrun devicectl install.
  DERIVED_DATA_PATH    DerivedData output path. Defaults to the user-level
                       Xcode cache (~/Library/Caches/Converlax/DerivedData)
                       so device builds never touch the working tree.

Current defaults target Kevin's paired iPad:
  XCODE_DEVICE_ID=00008103-000D792914E2201E
  DEVICETL_DEVICE_ID=90DDC869-C11E-55EA-A614-367493954585
USAGE
}

LAUNCH=false
case "${1:-}" in
  "")
    ;;
  "--launch")
    LAUNCH=true
    ;;
  "-h"|"--help")
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PROJECT="${PROJECT:-Converlax.xcodeproj}"
SCHEME="${SCHEME:-Converlax}"
CONFIGURATION="${CONFIGURATION:-Debug}"
XCODE_DEVICE_ID="${XCODE_DEVICE_ID:-00008103-000D792914E2201E}"
DEVICETL_DEVICE_ID="${DEVICETL_DEVICE_ID:-90DDC869-C11E-55EA-A614-367493954585}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$HOME/Library/Caches/Converlax/DerivedData}"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION-iphoneos/$SCHEME.app"
BUNDLE_ID="${BUNDLE_ID:-com.kego.converlax}"

cd "$REPO_ROOT"

echo "Checking paired device..."
xcrun devicectl list devices | grep -F "$DEVICETL_DEVICE_ID" >/dev/null || {
  echo "Device $DEVICETL_DEVICE_ID was not found by devicectl." >&2
  echo "Run: xcrun devicectl list devices" >&2
  exit 1
}

echo "Building $SCHEME for iPad..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=iOS,id=$XCODE_DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Build succeeded, but app bundle was not found at: $APP_PATH" >&2
  exit 1
fi

echo "Installing $APP_PATH..."
xcrun devicectl device install app \
  --device "$DEVICETL_DEVICE_ID" \
  "$APP_PATH"

if [[ "$LAUNCH" == true ]]; then
  echo "Launching $BUNDLE_ID..."
  xcrun devicectl device process launch \
    --device "$DEVICETL_DEVICE_ID" \
    "$BUNDLE_ID"
fi

echo "Done."
