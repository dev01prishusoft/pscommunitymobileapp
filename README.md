# PS Community Application

A production-ready Flutter application for the PrishuSoft Community, featuring secure payments, localization, and dynamic data integration.

## Architecture Notes
- Built using GetX for state management and routing.
- Uses standard Clean Architecture principles (Presentation, Domain, Data).
- Features rigorous separation between API data (Raw) and UI Localization (`.tr`).
- `Mapper` patterns are strictly enforced to handle enum and state resolution securely.

## Environment Setup
This application requires external API keys (`RAZORPAY_KEY` and `GOOGLEMAP_KEY`) to function properly.
Do **not** include `.env` as a Flutter asset in `pubspec.yaml` to prevent secret leakage in release binaries.

### Running Locally
To run the app on an emulator or physical device, inject the secrets via `--dart-define`:

```bash
flutter run --dart-define=RAZORPAY_KEY=your_key_here --dart-define=GOOGLEMAP_KEY=your_key_here
```

Alternatively, you can keep a local uncommitted `.env` file (which is gitignored) and inject it at compile time without packaging it as a release asset:

```bash
flutter run --dart-define-from-file=.env
```

### Running Tests
To verify UI components, mapper integrity, and ensure JSON locales remain valid, run:

```bash
flutter test
```

### Static Analysis
Before committing code, verify the absence of analyzer warnings:

```bash
flutter analyze
```

## Localization
- Core keys are stored in `lib/core/localization/translation_keys.dart`.
- Translations are managed in `assets/locales/en_US.json` and `assets/locales/gu_IN.json`.
- Dynamic strings originating from API data must never use `.tr`. Instead, use dedicated Mappers or leave the strings un-translated.
