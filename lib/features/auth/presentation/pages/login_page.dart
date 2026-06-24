import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_gradient_background.dart';
import 'package:pscommunitymobileapp/core/widgets/app_inline_error.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController(Get.find()));

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.pXl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppSpacing.vXxxl,
                  Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxxl,
                      vertical: 40,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            LK.welcomeBack.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.displaySmall.copyWith(
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          AppSpacing.vS,
                          Text(
                            LK.loginSubtitle.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          AppSpacing.vXxxl,
                          AppTextField(
                            label: LK.mobileNumber.tr,
                            controller: controller.mobileController,
                            hint: LK.mobileHint.tr,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: controller.validateMobile,
                          ),
                          AppSpacing.vXl,
                          Obx(
                            () => AppTextField(
                              label: LK.password.tr,
                              controller: controller.passwordController,
                              hint: LK.passwordHint.tr,
                              icon: Icons.lock_outline_rounded,
                              obscureText: controller.obscurePassword.value,
                              suffixIcon: IconButton(
                                onPressed: controller.togglePasswordVisibility,
                                tooltip: controller.obscurePassword.value
                                    ? 'Show Password'
                                    : 'Hide Password',
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              validator: controller.validatePassword,
                            ),
                          ),
                          AppSpacing.vXxxl,
                          Obx(
                            () => AppPrimaryButton(
                              text: LK.signIn.tr,
                              onPressed: controller.submit,
                              isLoading: controller.isFormLoading,
                            ),
                          ),
                          Obx(() {
                            final error = controller.formError.value;
                            if (error == null) return SizedBox.shrink();
                            return Column(
                              children: [
                                AppSpacing.vL,
                                AppInlineError(message: error),
                              ],
                            );
                          }),
                        ],
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
