#!/bin/bash
set -euo pipefail

NRY_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NRY_XCODE_DEVELOPER="/Applications/Xcode.app/Contents/Developer"
NRY_RENDER_BIN="/private/tmp/not-revenue-yet-render-demo"

if [[ -x "$NRY_XCODE_DEVELOPER/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc" ]]; then
  NRY_DEVELOPER_DIR="$NRY_XCODE_DEVELOPER"
  NRY_SWIFTC="$NRY_DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc"
  NRY_SDK="$NRY_DEVELOPER_DIR/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
else
  NRY_DEVELOPER_DIR="$(xcode-select -p)"
  NRY_SWIFTC="$(xcrun --find swiftc)"
  NRY_SDK="$(xcrun --show-sdk-path)"
fi

env -u CPATH \
  DEVELOPER_DIR="$NRY_DEVELOPER_DIR" \
  "$NRY_SWIFTC" \
  -parse-as-library \
  -O \
  -sdk "$NRY_SDK" \
  -framework AppKit \
  -framework AVFoundation \
  -framework CoreMedia \
  -framework CoreVideo \
  "$NRY_REPO_ROOT/scripts/render-demo.swift" \
  -o "$NRY_RENDER_BIN"

cd "$NRY_REPO_ROOT"
exec "$NRY_RENDER_BIN"
