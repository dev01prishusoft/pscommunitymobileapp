#!/bin/bash
# Builds the Flutter app for release with obfuscation and debug info splitting

echo "Building Android AppBundle (Release)..."
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

echo "Building Android APK (Release)..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

echo "Building iOS IPA (Release)..."
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols

echo "Build complete! Debug symbols are stored in build/app/outputs/symbols and build/ios/outputs/symbols."
