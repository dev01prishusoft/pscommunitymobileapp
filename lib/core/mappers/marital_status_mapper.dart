import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class MaritalStatusMapper {
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
        AppLogger.w('Unknown marital status: $status');
        return null;
    }
  }
}
