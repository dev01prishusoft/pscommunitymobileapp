$extraArgs = @()
if (Test-Path ".env") {
    $extraArgs += "--dart-define-from-file=.env"
}
$extraArgs += $args

Write-Host "Building Android AppBundle (Release)..."
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols @extraArgs

Write-Host "Building Android APK (Release)..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols @extraArgs

Write-Host "Building iOS IPA (Release)..."
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols @extraArgs

Write-Host "Build complete! Debug symbols are stored in build/app/outputs/symbols and build/ios/outputs/symbols."
