import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_inline_error.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_gradient_background.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    // Use Get.put with a unique tag so that if a new LoginPage is pushed while 
    // the old one is still animating out, they don't share the same controller.
    _controller = Get.put(
      LoginController(Get.find(), Get.find()), 
      tag: UniqueKey().toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      key: _controller.formKey,
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
                            controller: _controller.mobileController,
                            hint: LK.mobileHint.tr,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return LK.pleaseEnterMobile.tr;
                              }
                              if (!_controller.mobileRegex.hasMatch(
                                value.trim(),
                              )) {
                                return LK.pleaseEnterValidMobile.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Obx(() => AppTextField(
                            label: LK.password.tr,
                              controller: _controller.passwordController,
                            hint: LK.passwordHint.tr,
                            icon: Icons.lock_outline_rounded,
                              obscureText: _controller.obscurePassword.value,
                            suffixIcon: IconButton(
                                onPressed: _controller.togglePasswordVisibility,
                              icon: Icon(
                                  _controller.obscurePassword.value
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
                              onPressed: () => _controller.submit(),
                              isLoading: _controller.isLoading.value,
                          )),
                          Obx(() {
                            final error = _controller.error.value;
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

