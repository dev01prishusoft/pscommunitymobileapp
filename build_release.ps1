$ErrorActionPreference = "Stop"

if (-not (Test-Path .env)) {
    Write-Error ".env not found. Copy .env.example to .env and fill in the keys."
    exit 1
}

# Regenerate obfuscated secrets from .env. `clean` is required: build_runner
# does not track .env, so without it a stale cached env.g.dart is reused.
# Use the Dart bundled with Flutter; a standalone `dart` on PATH cannot build Flutter packages.
$Dart = Join-Path (Split-Path (Get-Command flutter).Source) "dart"
Write-Host "Generating secrets from .env..."
& $Dart run build_runner clean
& $Dart run build_runner build --delete-conflicting-outputs

Write-Host "Building Android AppBundle (Release)..."
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

Write-Host "Building Android APK (Release)..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

Write-Host "Building iOS IPA (Release)..."
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols

Write-Host "Build complete! Debug symbols are stored in build/app/outputs/symbols and build/ios/outputs/symbols."
