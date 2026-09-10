import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

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

  /// Translation key for the user-facing name of this module.
  String get displayNameKey {
    switch (this) {
      case AppModule.payment:
        return LK.payment;
      case AppModule.matrimonial:
        return LK.matrimonial;
      case AppModule.occupation:
        return LK.occupation;
      case AppModule.event:
        return LK.events;
      case AppModule.dailyNotification:
        return LK.notifications;
    }
  }

  /// Localized, user-friendly display name of the module.
  String get localizedName => displayNameKey.tr;

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
