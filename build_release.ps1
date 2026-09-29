Write-Host "Building Android AppBundle (Release)..."
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

Write-Host "Building Android APK (Release)..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

Write-Host "Building iOS IPA (Release)..."
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols

Write-Host "Build complete! Debug symbols are stored in build/app/outputs/symbols and build/ios/outputs/symbols."
