import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_inline_error.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_gradient_background.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileRegex = RegExp(r'^[0-9]{10}$');

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (kUiReviewMode) {
      Get.offNamed(AppRouter.postLoginSplash);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<LoginController>();
    final success = await controller.login(
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
    );

    if (success) Get.offNamed(AppRouter.postLoginSplash);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Container(
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
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            LK.welcomeBack.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            LK.loginSubtitle.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            label: LK.mobileNumber.tr,
                            controller: _mobileController,
                            hint: LK.mobileHint.tr,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return LK.pleaseEnterMobile.tr;
                              }
                              if (!_mobileRegex.hasMatch(value.trim())) {
                                return LK.pleaseEnterValidMobile.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LK.password.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(AppRouter.resetPassword),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  LK.forgotPassword.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Obx(() => AppTextField(
                            controller: _passwordController,
                            hint: LK.passwordHint.tr,
                            icon: Icons.lock_outline_rounded,
                            obscureText: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              onPressed: controller.togglePasswordVisibility,
                              icon: Icon(
                                controller.obscurePassword.value
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
                          )),
                          const SizedBox(height: 32),
                          Obx(() => AppPrimaryButton(
                            text: LK.signIn.tr,
                            onPressed: _submit,
                            isLoading: controller.isLoading.value,
                          )),
                          Obx(() {
                            final error = controller.error.value;
                            if (error == null) return const SizedBox.shrink();
                            return Column(
                              children: [
                                const SizedBox(height: 16),
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
