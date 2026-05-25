import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

class AuthState {
  AuthState(this._tokenManager) {
    _updateAuthStatus();
    ever(_tokenManager.authState, (_) => _updateAuthStatus());
  }

  final TokenManager _tokenManager;
  final RxBool isAuthenticated = false.obs;

  void _updateAuthStatus() {
    isAuthenticated.value = _tokenManager.hasToken;
  }

  void logout() {
    _tokenManager.clearTokens();
    if (Get.isRegistered<SamajController>()) {
      Get.find<SamajController>().clear();
    }
    Get.find<LocalizationService>().changeLocale('en', 'US');
  }

  Future<void> logoutAndRedirect() async {
    await _tokenManager.clearTokens();
    if (Get.isRegistered<SamajController>()) {
      Get.find<SamajController>().clear();
    }
    await Get.offAllNamed<void>(AppRouter.login);
  }
}
