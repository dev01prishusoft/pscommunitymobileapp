import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/core/utils/form_state_mixin.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

enum LoginResult { success, requirePasswordReset, failure, uiReview }

class LoginController extends GetxController with FormStateMixin {
  LoginController(this._loginUseCase);
  final LoginUseCase _loginUseCase;

  final RxBool obscurePassword = true.obs;
  final Rx<LoginResult?> loginResult = Rx<LoginResult?>(null);

  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final localizationService = Get.find<LocalizationService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      localizationService.currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(const Locale('en', 'US'));
    });

    ever(loginResult, (LoginResult? result) async {
      switch (result) {
        case LoginResult.uiReview:
        case LoginResult.success:
          await localizationService.restoreSavedLocale();
          unawaited(Get.offNamed(AppRouter.postLoginSplash));
          break;
        case LoginResult.requirePasswordReset:
          unawaited(Get.offNamed(AppRouter.resetPassword));
          break;
        case LoginResult.failure:
        case null:
          break;
      }
    });
  }

  @override
  void onClose() {
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void submit() {
    if (kUiReviewMode) {
      loginResult.value = LoginResult.uiReview;
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) return;

    submitThrottled(() async {
      loginResult.value = await _login(
        mobile: mobileController.text.trim(),
        password: passwordController.text,
      );
    });
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  String? validateMobile(String? value) => AppValidators.mobile(value);

  String? validatePassword(String? value) => AppValidators.password(value);

  Future<LoginResult> _login({
    required String mobile,
    required String password,
  }) async {
    final result = await _loginUseCase.call(mobile: mobile, password: password);

    if (result is Success<AuthTokens>) {
      await Get.find<SamajController>().fetchSamajDetail();
      return result.data.isDefaultPassword
          ? LoginResult.requirePasswordReset
          : LoginResult.success;
    } else {
      formError.value = (result as Error<AuthTokens>).failure.message;
      return LoginResult.failure;
    }
  }
}
