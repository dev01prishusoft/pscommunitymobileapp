import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
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
        AppLogger.w('Unknown relation: $relation');
        return null;
    }
  }
}
