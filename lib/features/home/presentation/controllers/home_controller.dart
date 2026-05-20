import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';

/// Controller for the Home screen.
/// Owns all logic that should NOT live in the UI — currently fetching
/// the available languages for the language-switcher dropdown.
class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Fetch supported languages once. LocalizationService guards
    // against duplicate in-flight calls.
    Get.find<LocalizationService>().fetchLanguages();
  }
}
