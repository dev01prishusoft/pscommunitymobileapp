#!/bin/bash
# Builds the Flutter app for release with obfuscation and debug info splitting
set -e

if [ ! -f .env ]; then
  echo "ERROR: .env not found. Copy .env.example to .env and fill in the keys."
  exit 1
fi

# Regenerate obfuscated secrets from .env. `clean` is required: build_runner
# does not track .env, so without it a stale cached env.g.dart is reused.
# Use the Dart bundled with Flutter; a standalone `dart` on PATH cannot build Flutter packages.
DART="$(dirname "$(command -v flutter)")/dart"
echo "Generating secrets from .env..."
"$DART" run build_runner clean
"$DART" run build_runner build --delete-conflicting-outputs

echo "Building Android AppBundle (Release)..."
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

echo "Building Android APK (Release)..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

echo "Building iOS IPA (Release)..."
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols

echo "Build complete! Debug symbols are stored in build/app/outputs/symbols and build/ios/outputs/symbols."
