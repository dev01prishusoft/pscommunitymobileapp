import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

class LoginController extends GetxController {

  LoginController(this._loginUseCase, this._tokenManager);
  final LoginUseCase _loginUseCase;
  final TokenManager _tokenManager;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxBool obscurePassword = true.obs;

  

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<AuthTokens?> login({
    required String mobile,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final newTokens = await _loginUseCase.call(mobile: mobile, password: password);
      await _tokenManager.saveTokens(newTokens.accessToken, newTokens.refreshToken);
      
      // Fetch Samaj details globally
      Get.find<SamajController>().fetchSamajDetail();
      
      return newTokens;
    } on Failure catch (f) {
      if (f.message.contains('Invalid Email/ Password')) {
        error.value = LK.invalidMobileOrPassword.tr;
      } else {
        error.value = f.message;
      }
      return null;
    } catch (e) {
      error.value = LK.errorServer.tr;
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
