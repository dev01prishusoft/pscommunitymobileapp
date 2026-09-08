/// Enum representing the core modules supported by the application.
/// Values match the backend codes specified in the module permission API documentation.
enum AppModule {
  payment('PAYMENT'),
  matrimonial('MATRIMONIAL'),
  occupation('OCCUPATION'),
  event('EVENT'),
  dailyNotification('DAILY_NOTIFICATION');

  final String code;
  const AppModule(this.code);

  /// Safe lookup from string code (case-insensitive, trimmed).
  static AppModule? fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    final normalized = code.trim().toUpperCase();
    for (final module in AppModule.values) {
      if (module.code == normalized) {
        return module;
      }
    }
    return null;
  }

  /// Safe lookup returning a fallback if not found.
  static AppModule fromCodeOrDefault(String? code, AppModule defaultValue) {
    return fromCode(code) ?? defaultValue;
  }

  /// Check if a given code matches this module.
  bool matches(String? otherCode) {
    if (otherCode == null) return false;
    return code == otherCode.trim().toUpperCase();
  }
}
