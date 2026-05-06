import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_gradient_background.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResetPasswordController>();
    final formKey = GlobalKey<FormState>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Future<void> submit() async {
      if (kUiReviewMode) {
        Get.offNamed(AppRouter.postLoginSplash);
        return;
      }

      if (!formKey.currentState!.validate()) return;

      final success = await controller.resetPassword(newPasswordController.text);

      if (success) {
        Get.offNamed(AppRouter.postLoginSplash);
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondary),
          onPressed: () => Get.back(),
        ),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            label: LK.newPassword.tr,
                            controller: newPasswordController,
                            hint: LK.passwordHint.tr,
                            icon: Icons.lock_outline_rounded,
                            obscureText: controller.obscureNewPassword.value,
                            suffixIcon: IconButton(
                              onPressed: controller.toggleNewPasswordVisibility,
                              icon: Icon(
                                controller.obscureNewPassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LK.pleaseEnterPassword.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            label: LK.confirmNewPassword.tr,
                            controller: confirmPasswordController,
                            hint: LK.passwordHint.tr,
                            icon: Icons.lock_outline_rounded,
                            obscureText: controller.obscureConfirmPassword.value,
                            suffixIcon: IconButton(
                              onPressed: controller.toggleConfirmPasswordVisibility,
                              icon: Icon(
                                controller.obscureConfirmPassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LK.pleaseEnterPassword.tr;
                              }
                              if (value != newPasswordController.text) {
                                return LK.passwordsDoNotMatch.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          AppPrimaryButton(
                            text: LK.updatePassword.tr,
                            onPressed: submit,
                            isLoading: controller.isLoading.value,
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
