import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart'
    as pscommunitymobileapp_api_client;
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

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
    locService.resetToDefaultLocale();
  }

  Future<void> _revokeTokenCall() async {
    final token = _tokenManager.refreshToken;
    if (token != null && token.isNotEmpty) {
      try {
        if (Get.isRegistered<pscommunitymobileapp_api_client.ApiClient>()) {
          final apiClient =
              Get.find<pscommunitymobileapp_api_client.ApiClient>();
          try {
            final deviceUniqueId = _tokenManager.authState.value.deviceUniqueId;
            final queryParams =
                deviceUniqueId != null && deviceUniqueId.isNotEmpty
                ? '?tokenUniqueId=$deviceUniqueId'
                : '';

            await apiClient
                .post(
                  '/api/v1/auth/member-revoke-token$queryParams',
                  data:
                      '"$token"',
                )
                .timeout(const Duration(seconds: 5));
          } catch (_) {}
        }
      } catch (_) {}
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
      await locService.resetToDefaultLocale();
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
          await apiClient.post('/api/v1/member/active-inactive/$memberId');
        } catch (_) {
        }
      }
    }
    await logoutAndRedirect();
  }
}
