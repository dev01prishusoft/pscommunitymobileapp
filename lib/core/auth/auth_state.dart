import 'package:get/get.dart';
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
    isAuthenticated.value = _tokenManager.hasToken;
  }

  void logout() {
    _tokenManager.clearTokens();
  }
}
