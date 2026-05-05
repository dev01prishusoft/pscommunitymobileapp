import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class LoginController extends GetxController {
  final LoginUseCase _loginUseCase;
  final TokenManager _tokenManager;

  LoginController(this._loginUseCase, this._tokenManager);

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<bool> login({
    required String mobile,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final newTokens = await _loginUseCase.call(mobile: mobile, password: password);
      await _tokenManager.saveTokens(newTokens.accessToken, newTokens.refreshToken);
      return true;
    } on Failure catch (f) {
      error.value = f.translationKey.tr;
      return false;
    } catch (e) {
      error.value = LK.errorServer.tr;
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
