// ignore_for_file: unawaited_futures, inference_failure_on_function_invocation
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/utils/form_state_mixin.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

enum LoginResult { success, requirePasswordReset, failure }

class LoginController extends GetxController with FormStateMixin {
  LoginController(this._loginUseCase);
  final LoginUseCase _loginUseCase;
  
  final RxBool obscurePassword = true.obs;

  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    Future.delayed(const Duration(milliseconds: 500), () {
      mobileController.dispose();
      passwordController.dispose();
    });
    super.onClose();
  }

  void submit() {
    if (kUiReviewMode) {
      Get.offNamed(AppRouter.postLoginSplash);
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) return;

    submitThrottled(() async {
      final result = await _login(
        mobile: mobileController.text.trim(),
        password: passwordController.text,
      );

      switch (result) {
        case LoginResult.requirePasswordReset:
          Get.offNamed(AppRouter.resetPassword);
          break;
        case LoginResult.success:
          Get.offNamed(AppRouter.postLoginSplash);
          break;
        case LoginResult.failure:
          break;
      }
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
    final result = await _loginUseCase.call(
      mobile: mobile,
      password: password,
    );
    
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

