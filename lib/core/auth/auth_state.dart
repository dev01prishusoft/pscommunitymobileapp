import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart' as pscommunitymobileapp_api_client;
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
    locService.changeLocale('en', 'US');
  }

  Future<void> _revokeTokenCall() async {
    final token = _tokenManager.refreshToken;
    if (token != null && token.isNotEmpty) {
      try {
        // Can't inject ApiClient via constructor due to circular dependency, so lazy find it
        if (Get.isRegistered<pscommunitymobileapp_api_client.ApiClient>()) {
          final apiClient = Get.find<pscommunitymobileapp_api_client.ApiClient>();
          
          AppLogger.i('================ REVOKE TOKEN REQUEST ================');
          AppLogger.i('URL: /api/v1/auth/member-revoke-token');
          AppLogger.i('PAYLOAD: { "refreshToken": "$token" }');

          try {
            final deviceUniqueId = _tokenManager.authState.value.deviceUniqueId;
            final queryParams = deviceUniqueId != null && deviceUniqueId.isNotEmpty 
                ? '?tokenUniqueId=$deviceUniqueId' 
                : '';
                
            AppLogger.i('URL: /api/v1/auth/member-revoke-token$queryParams');

            final response = await apiClient.post(
              '/api/v1/auth/member-revoke-token$queryParams', 
              data: '"$token"' // The Swagger UI shows the body is just a string, not an object
            ).timeout(const Duration(seconds: 5));

            AppLogger.i('================ REVOKE TOKEN RESPONSE ================');
            AppLogger.i('STATUS CODE: ${response.statusCode}');
            AppLogger.i('DATA: ${response.data}');
            AppLogger.i('=====================================================');
          } catch (e) {
            AppLogger.e('REVOKE TOKEN FAILED: $e');
          }
        }
      } catch (e) {
        AppLogger.e('REVOKE TOKEN OUTER CATCH', e);
      }
    } else {
      AppLogger.w('REVOKE TOKEN SKIPPED: No refresh token found.');
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
