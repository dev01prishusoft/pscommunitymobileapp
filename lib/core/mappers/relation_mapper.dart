import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class RelationMapper {
  /// Returns the localization key for a given relation string.
  /// If no match is found, returns the raw string as a fallback.
  static String? getLabelKey(String? relation) {
    if (relation == null || relation.isEmpty) return null;
    
    switch (relation.toLowerCase()) {
      case 'self':
        return LK.self;
      case 'wife':
        return LK.wife;
      default:
        if (kDebugMode) debugPrint('Unknown relation: $relation');
        return null;
    }
  }
}
