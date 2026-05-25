// ignore_for_file: unawaited_futures, inference_failure_on_function_invocation
import 'dart:async';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_gradient_background.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    mobileController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResetPasswordController>();

    Future<void> submit() async {
      if (kUiReviewMode) {
        Get.offNamed<void>(AppRouter.postLoginSplash);
        return;
      }

      if (!formKey.currentState!.validate()) return;

      await controller.resetPassword(
        mobileController.text,
        oldPasswordController.text,
        newPasswordController.text,
      );

      if (controller.isFormSuccess) {
        Get.snackbar(
          LK.success.tr,
          LK.successUpdate.tr,
          backgroundColor: AppColors.green,
          colorText: AppColors.white,
        );
        Get.offNamed<void>(AppRouter.postLoginSplash);
      } else if (controller.isFormError && controller.formError.value != null) {
        Get.snackbar(
          LK.errorServer.tr,
          controller.formError.value!,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondary,
          ),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Container(
                      constraints: BoxConstraints(maxWidth: 500),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              LK.resetPassword.tr,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.displaySmall.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 32.h),
                            AppTextField(
                              label: LK.mobileNumber.tr,
                              controller: mobileController,
                              hint: LK.mobileHint.tr,
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              validator: AppValidators.mobile,
                            ),
                            SizedBox(height: 20.h),
                            AppTextField(
                              label: LK.oldPassword.tr,
                              controller: oldPasswordController,
                              hint: LK.passwordHint.tr,
                              icon: Icons.lock_open_rounded,
                              obscureText: true,
                              validator: AppValidators.required,
                            ),
                            SizedBox(height: 20.h),
                            AppTextField(
                              label: LK.newPassword.tr,
                              controller: newPasswordController,
                              hint: LK.passwordHint.tr,
                              icon: Icons.lock_outline_rounded,
                              obscureText: controller.obscureNewPassword.value,
                              suffixIcon: IconButton(
                                onPressed:
                                    controller.toggleNewPasswordVisibility,
                                icon: Icon(
                                  controller.obscureNewPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              validator: AppValidators.password,
                            ),
                            SizedBox(height: 20.h),
                            AppTextField(
                              label: LK.confirmNewPassword.tr,
                              controller: confirmPasswordController,
                              hint: LK.passwordHint.tr,
                              icon: Icons.lock_outline_rounded,
                              obscureText:
                                  controller.obscureConfirmPassword.value,
                              suffixIcon: IconButton(
                                onPressed:
                                    controller.toggleConfirmPasswordVisibility,
                                icon: Icon(
                                  controller.obscureConfirmPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LK.pleaseEnterConfirmPassword.tr;
                                }
                                if (value != newPasswordController.text) {
                                  return LK.passwordsDoNotMatch.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 32.h),
                            Obx(
                              () => AppPrimaryButton(
                                text: LK.updatePassword.tr,
                                onPressed: submit,
                                isLoading: controller.isFormLoading,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
