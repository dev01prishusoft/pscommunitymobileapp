import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';

class LoginController extends GetxController {
  final LoginUseCase _loginUseCase;

  LoginController(this._loginUseCase);

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final Rxn<AuthTokens> tokens = Rxn<AuthTokens>();

  Future<bool> login({
    required String mobile,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      tokens.value = await _loginUseCase.call(mobile: mobile, password: password);
      return true;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
