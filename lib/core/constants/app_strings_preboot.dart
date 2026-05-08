/// PRE-BOOTSTRAP STRINGS
/// 
/// These strings are used when the app crashes before the localization 
/// system (GetX) is initialized. They are intentionally hardcoded in English
/// to ensure the user sees an error message even if the JSON translations
/// fail to load.
abstract class PrebootStrings {
  static const String initError = 'System Initialization Error';
  static const String initBody = 'The community hub could not be started safely.';
  static const String errorLog = 'ERROR LOG';
  static const String closeApp = 'CLOSE APP & RESTART';
  static const String unknownError = 'An unexpected error occurred during startup.';
}
