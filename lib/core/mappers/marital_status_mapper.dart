import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class MaritalStatusMapper {
  /// Returns the localization key for a given marital status string.
  /// If no match is found, returns the raw string as a fallback.
  static String? getLabelKey(String? status) {
    if (status == null || status.isEmpty) return null;
    
    switch (status.toLowerCase()) {
      case 'married':
        return LK.married;
      case 'unmarried':
        return LK.unmarried;
      case 'single':
        return LK.unmarried;
      default:
        if (kDebugMode) debugPrint('Unknown marital status: $status');
        return null;
    }
  }
}
