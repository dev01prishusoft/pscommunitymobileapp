# PS Community Application

A production-ready Flutter application for the PrishuSoft Community, featuring secure payments, localization, and dynamic data integration.

## Architecture Notes
- Built using GetX for state management and routing.
- Uses standard Clean Architecture principles (Presentation, Domain, Data).
- Features rigorous separation between API data (Raw) and UI Localization (`.tr`).
- `Mapper` patterns are strictly enforced to handle enum and state resolution securely.

## Configuration
The Google Places API key is not bundled with the app. It is fetched at runtime from `GET /api/v1/AppSetting` (`AppSettingService`). If the key is unavailable, location fields fall back to plain text input.

### Running Locally
```bash
flutter run
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
