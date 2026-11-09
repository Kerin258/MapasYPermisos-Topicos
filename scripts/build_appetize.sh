#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/salida"
xcodebuild -version
xcodebuild -project "$ROOT/MapasYPermisos.xcodeproj" \
  -scheme MapasYPermisos \
  -configuration Release \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$ROOT/.build" \
  ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO \
  build | tee "$ROOT/salida/compilacion.log"
APP="$ROOT/.build/Build/Products/Release-iphonesimulator/MapasYPermisos.app"
test -d "$APP"
/usr/bin/plutil -lint "$APP/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :NSLocationWhenInUseUsageDescription' "$APP/Info.plist"
/usr/bin/lipo -info "$APP/MapasYPermisos"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent \
  "$APP" "$ROOT/salida/MapasYPermisos-Appetize.zip"
/usr/bin/unzip -t "$ROOT/salida/MapasYPermisos-Appetize.zip"
echo "Archivo para subir a Appetize: salida/MapasYPermisos-Appetize.zip"
