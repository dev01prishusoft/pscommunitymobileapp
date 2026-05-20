import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';

class AuthState {
  final TokenManager _tokenManager;
  final RxBool isAuthenticated = false.obs;

  AuthState(this._tokenManager) {
    _updateAuthStatus();
    // Listen to token changes
    ever(_tokenManager.accessToken, (_) => _updateAuthStatus());
  }

  void _updateAuthStatus() {
    // hasValidToken checks both presence and JWT expiry
    isAuthenticated.value = _tokenManager.hasValidToken;
  }

  void logout() {
    _tokenManager.clearTokens();
  }

  /// Clears tokens and redirects to the login screen.
  /// Called automatically when the refresh token is expired or invalid.
  Future<void> logoutAndRedirect() async {
    await _tokenManager.clearTokens();
    await Get.offAllNamed<void>(AppRouter.login);
  }
}
