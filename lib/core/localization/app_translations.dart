import 'package:get/get.dart';

class AppTranslations extends Translations {
  final Map<String, Map<String, String>> translationKeys;

  AppTranslations(this.translationKeys);

  @override
  Map<String, Map<String, String>> get keys => translationKeys;
}
