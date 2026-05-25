import 'package:get/get.dart';

class AppTranslations extends Translations {
  AppTranslations(this.translationKeys);
  final Map<String, Map<String, String>> translationKeys;

  @override
  Map<String, Map<String, String>> get keys => translationKeys;
}
