import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class RelationMapper {
  static String? getLabelKey(String? relation) {
    if (relation == null || relation.isEmpty) return null;

    switch (relation.toLowerCase()) {
      case 'self':
        return LK.self;
      case 'wife':
        return LK.wife;
      default:
        // Gracefully fallback to the raw relation string so the UI can display it
        // and .tr can translate it if the key is added later.
        return relation;
    }
  }
}
