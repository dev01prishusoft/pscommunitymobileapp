import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

enum LoginResult { success, requirePasswordReset, failure }

class LoginController extends GetxController {

  LoginController(this._loginUseCase, this._tokenManager);
  final LoginUseCase _loginUseCase;
  final TokenManager _tokenManager;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxBool obscurePassword = true.obs;

  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileRegex = RegExp(r'^[0-9]{10}$');

  @override
  void onClose() {
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> submit(GlobalKey<FormState> formKey) async {
    if (isLoading.value) return;

    if (kUiReviewMode) {
      Get.offNamed<void>(AppRouter.postLoginSplash);
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) return;

    final result = await login(
      mobile: mobileController.text.trim(),
      password: passwordController.text,
    );

    switch (result) {
      case LoginResult.requirePasswordReset:
        Get.offNamed<void>(AppRouter.resetPassword);
        break;
      case LoginResult.success:
        Get.offNamed<void>(AppRouter.postLoginSplash);
        break;
      case LoginResult.failure:
        // Error is already handled and displayed
        break;
    }
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<LoginResult> login({
    required String mobile,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final newTokens = await _loginUseCase.call(mobile: mobile, password: password);
      await _tokenManager.saveTokens(newTokens.accessToken, newTokens.refreshToken);
      
      // Fetch Samaj details globally
      await Get.find<SamajController>().fetchSamajDetail();
      
      return newTokens.isDefaultPassword 
          ? LoginResult.requirePasswordReset 
          : LoginResult.success;
    } on Failure catch (f) {
      final msg = f.message.toLowerCase();
      if (msg.contains('invalid') && (msg.contains('mobile') || msg.contains('password') || msg.contains('email') || msg.contains('credentials'))) {
        error.value = LK.invalidMobileOrPassword.tr;
      } else {
        error.value = f.message;
      }
      return LoginResult.failure;
    } catch (e) {
      error.value = LK.errorServer.tr;
      return LoginResult.failure;
    } finally {
      isLoading.value = false;
    }
  }
}
