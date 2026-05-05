import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';

class LoginController extends GetxController {
  final LoginUseCase _loginUseCase;
  final _storage = const FlutterSecureStorage();

  LoginController(this._loginUseCase) {
    _loadTokens();
  }

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final Rxn<AuthTokens> tokens = Rxn<AuthTokens>();
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<void> _loadTokens() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (accessToken != null && refreshToken != null) {
      tokens.value = AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    tokens.value = null;
  }

  Future<bool> login({
    required String mobile,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final newTokens = await _loginUseCase.call(mobile: mobile, password: password);
      await _storage.write(key: 'access_token', value: newTokens.accessToken);
      await _storage.write(key: 'refresh_token', value: newTokens.refreshToken);
      tokens.value = newTokens;
      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('401')) {
        error.value = 'Invalid mobile number or password'.tr;
      } else if (errorMessage.contains('TimeoutException')) {
        error.value = 'Connection timed out. Please try again.'.tr;
      } else {
        error.value = 'Login failed. Please check your credentials.'.tr;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
