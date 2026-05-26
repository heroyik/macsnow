#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")"
APP_NAME="MacSnow"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"
STAGING_DIR="$DIST_DIR/dmg-staging"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

cd "$ROOT_DIR"

cleanup_staging() {
    if [[ -x "$LSREGISTER" && -d "$STAGING_DIR/$APP_NAME.app" ]]; then
        "$LSREGISTER" -u "$STAGING_DIR/$APP_NAME.app" >/dev/null 2>&1 || true
    fi
    rm -rf "$STAGING_DIR"
}

cleanup_dist_registration() {
    if [[ -x "$LSREGISTER" && -d "$APP_DIR" ]]; then
        "$LSREGISTER" -u "$APP_DIR" >/dev/null 2>&1 || true
    fi
}

trap cleanup_staging EXIT

bash "$ROOT_DIR/Scripts/build_app_bundle.sh"

rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"

ditto "$APP_DIR" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
    -volname "$APP_NAME $VERSION" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

cleanup_staging
cleanup_dist_registration
trap - EXIT

echo "Built $DMG_PATH"
