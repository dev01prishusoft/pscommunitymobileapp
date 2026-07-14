import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class GenderMapper {
  static String? getLabelKey(String? gender) {
    if (gender == null || gender.isEmpty) return null;

    switch (gender.toLowerCase()) {
      case 'male':
        return LK.male;
      case 'female':
        return LK.female;
      default:
        return null;
    }
  }
}
