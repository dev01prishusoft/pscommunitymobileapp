import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class GenderMapper {
  /// Returns the localization key for a given gender string.
  /// If no match is found, returns the raw string as a fallback.
  static String? getLabelKey(String? gender) {
    if (gender == null || gender.isEmpty) return null;
    
    switch (gender.toLowerCase()) {
      case 'male':
        return LK.male;
      case 'female':
        return LK.female;
      default:
        if (kDebugMode) debugPrint('Unknown gender: $gender');
        return null;
    }
  }
}
