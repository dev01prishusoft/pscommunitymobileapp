import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart' as pscommunitymobileapp_api_client;

class AuthState {
  AuthState(this._tokenManager) {
    _updateAuthStatus();
    ever(_tokenManager.authState, (_) => _updateAuthStatus());
  }

  final TokenManager _tokenManager;
  final RxBool isAuthenticated = false.obs;
  bool _isLoggingOut = false;

  void _updateAuthStatus() {
    isAuthenticated.value = _tokenManager.hasToken;
  }

  void logout() {
    _revokeTokenCall();
    _tokenManager.clearTokens();
    if (Get.isRegistered<SamajController>()) {
      Get.find<SamajController>().clear();
    }
    final locService = Get.find<LocalizationService>();
    locService.clearLanguages();
    locService.changeLocale('en', 'US');
  }

  Future<void> _revokeTokenCall() async {
    final token = _tokenManager.refreshToken;
    if (token != null && token.isNotEmpty) {
      try {
        // Can't inject ApiClient via constructor due to circular dependency, so lazy find it
        if (Get.isRegistered<pscommunitymobileapp_api_client.ApiClient>()) {
          final apiClient = Get.find<pscommunitymobileapp_api_client.ApiClient>();
          await apiClient.post(
            '/api/v1/auth/member-revoke-token', 
            data: {'refreshToken': token}
          ).timeout(const Duration(seconds: 5));
        }
      } catch (e) {
        // Ignore failure on logout
      }
    }
  }

  Future<void> logoutAndRedirect() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    try {
      await _revokeTokenCall();
      await _tokenManager.clearTokens();
      if (Get.isRegistered<SamajController>()) {
        Get.find<SamajController>().clear();
      }
      final locService = Get.find<LocalizationService>();
      locService.clearLanguages();
      await locService.changeLocale('en', 'US');
      if (Get.currentRoute != AppRouter.login) {
        await Get.offAllNamed<void>(AppRouter.login);
      }
    } finally {
      _isLoggingOut = false;
    }
  }

  Future<void> deleteAccountAndRedirect() async {
    final memberId = _tokenManager.memberId;
    if (memberId != null) {
      if (Get.isRegistered<pscommunitymobileapp_api_client.ApiClient>()) {
        final apiClient = Get.find<pscommunitymobileapp_api_client.ApiClient>();
        try {
          await apiClient.post(
            '/api/v1/member/active-inactive/$memberId',
          );
        } catch (_) {
          // Continue to logout even if api call fails
        }
      }
    }
    await logoutAndRedirect();
  }
}
