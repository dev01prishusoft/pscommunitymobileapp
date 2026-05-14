# PS Community Application

A production-ready Flutter application for the PrishuSoft Community, featuring secure payments, localization, and dynamic data integration.

## Architecture Notes
- Built using GetX for state management and routing.
- Uses standard Clean Architecture principles (Presentation, Domain, Data).
- Features rigorous separation between API data (Raw) and UI Localization (`.tr`).
- `Mapper` patterns are strictly enforced to handle enum and state resolution securely.

## Environment Setup
This application requires an external Razorpay API key to function properly.
Do **not** use a hardcoded `.env` file for production binaries to prevent secret leakage.

### Running Locally
To run the app on an emulator or physical device, inject the `RAZORPAY_KEY` using `--dart-define`:

```bash
flutter run --dart-define=RAZORPAY_KEY=your_key_here
```

### Running Tests
To verify UI components, mapper integrity, and ensure JSON locales remain valid, run:

```bash
flutter test
```

### Static Analysis
Before committing code, verify the absence of invalid translation uses and analyzer warnings:

```bash
# Check for analyzer errors
flutter analyze

# Scan for unsafe .tr bindings in UI files
dart run tool/check_invalid_tr_usage.dart

# Check for duplicate localization keys
dart run tool/check_duplicate_lk_values.dart
```

## Localization
- Core keys are stored in `lib/core/localization/translation_keys.dart`.
- Translations are managed in `assets/locales/en_US.json` and `assets/locales/gu_IN.json`.
- Dynamic strings originating from API data must never use `.tr`. Instead, use dedicated Mappers or leave the strings un-translated.
