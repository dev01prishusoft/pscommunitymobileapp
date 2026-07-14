import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/app_validators.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/reset_password_controller.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final localizationService = Get.find<LocalizationService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      localizationService.currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(const Locale('en', 'US'));
    });
  }

  @override
  void dispose() {
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

      final phone = Get.find<TokenManager>().userPhone ?? '';
      await controller.resetPassword(phone, phone, newPasswordController.text);

      if (controller.isFormSuccess) {
        PSDelightToastBar(
          snackbarDuration: const Duration(seconds: 3),
          builder: (context) =>
              ToastCard(title: LK.success, subtitle: LK.successUpdate),
        ).show();
        await Get.find<LocalizationService>().restoreSavedLocale();
        Get.offNamed<void>(AppRouter.postLoginSplash);
      } else if (controller.isFormError && controller.formError.value != null) {
        PSDelightToastBar(
          snackbarDuration: const Duration(seconds: 3),
          builder: (context) => ToastCard(
            title: LK.errorServer,
            subtitle: controller.formError.value!,
            isErrorMessage: true,
          ),
        ).show();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Get.back<void>();
        } else {
          Get.find<AuthState>().logoutAndRedirect();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.black,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Get.back<void>();
              } else {
                Get.find<AuthState>().logoutAndRedirect();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.pXl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Card(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Form(
                        key: formKey,
                        child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  LK.resetPassword,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.displaySmall.copyWith(
                                    color: AppColors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 32.h),
                                AppTextField(
                                  label: LK.newPassword,
                                  controller: newPasswordController,
                                  hint: LK.passwordHint,
                                  icon: Iconsax.lock_circle_copy,
                                  obscureText:
                                      controller.obscureNewPassword.value,
                                  suffixIcon: IconButton(
                                    onPressed:
                                        controller.toggleNewPasswordVisibility,
                                    icon: Icon(
                                      controller.obscureNewPassword.value
                                          ? Iconsax.eye_copy
                                          : Iconsax.eye_slash_copy,
                                      color: AppColors.grey,
                                      size: 20.sp,
                                    ),
                                  ),
                                  validator: AppValidators.complexPassword,
                                ),
                                SizedBox(height: 20.h),
                                AppTextField(
                                  label: LK.confirmNewPassword,
                                  controller: confirmPasswordController,
                                  hint: LK.passwordHint,
                                  icon: Iconsax.lock_circle_copy,
                                  obscureText:
                                      controller.obscureConfirmPassword.value,
                                  suffixIcon: IconButton(
                                    onPressed: controller
                                        .toggleConfirmPasswordVisibility,
                                    icon: Icon(
                                      controller.obscureConfirmPassword.value
                                          ? Iconsax.eye_copy
                                          : Iconsax.eye_slash_copy,
                                      color: AppColors.grey,
                                      size: 20.sp,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return LK.pleaseEnterConfirmPassword;
                                    }
                                    if (value != newPasswordController.text) {
                                      return LK.passwordsDoNotMatch;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 32.h),
                                Obx(
                                  () => AppPrimaryButton(
                                    text: LK.updatePassword,
                                    onPressed: submit,
                                    isLoading: controller.isFormLoading,
                                  ),
                                ),
                              ],
                            ).paddingSymmetric(
                              horizontal: AppSpacing.xxxl,
                              vertical: 40.h,
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
