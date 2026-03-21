#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "==> Flutter clean & deps"
flutter clean
flutter pub get

echo "==> Build split APKs"
flutter build apk --release --split-per-abi

echo "==> Build AAB"
flutter build appbundle --release

echo "\n==> Output files"
APK_DIR="$PROJECT_DIR/build/app/outputs/flutter-apk"
AAB_DIR="$PROJECT_DIR/build/app/outputs/bundle/release"

ls -lh "$APK_DIR"/*release*.apk 2>/dev/null || true
ls -lh "$AAB_DIR"/*.aab 2>/dev/null || true

echo "\n==> Size summary"
du -h "$APK_DIR"/*release*.apk 2>/dev/null || true
du -h "$AAB_DIR"/*.aab 2>/dev/null || true

echo "\nDone."
