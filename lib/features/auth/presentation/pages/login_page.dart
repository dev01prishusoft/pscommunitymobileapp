import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_inline_error.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(LoginController(Get.find()));
    final localizationService = Get.find<LocalizationService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      localizationService.currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(const Locale('en', 'US'));
    });
  }

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pXl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/app_logo.png', height: 100.h),
                AppSpacing.vXxxl,
                Card(
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
                              LK.welcomeBack.tr,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.displaySmall.copyWith(
                                color: AppColors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            AppSpacing.vS,
                            Text(
                              LK.loginSubtitle.tr,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            AppSpacing.vXxxl,
                            AppTextField(
                              label: LK.mobileNumber.tr,
                              controller: mobileController,
                              hint: LK.mobileHint.tr,
                              icon: Iconsax.mobile_copy,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _controller.validateMobile,
                            ),
                            AppSpacing.vXl,
                            Obx(
                              () => AppTextField(
                                label: LK.password.tr,
                                controller: passwordController,
                                hint: LK.passwordHint.tr,
                                icon: Iconsax.lock_circle_copy,
                                obscureText: _controller.obscurePassword.value,
                                suffixIcon: IconButton(
                                  onPressed:
                                      _controller.togglePasswordVisibility,
                                  tooltip: _controller.obscurePassword.value
                                      ? 'Show Password'
                                      : 'Hide Password',
                                  icon: Icon(
                                    _controller.obscurePassword.value
                                        ? Iconsax.eye_copy
                                        : Iconsax.eye_slash_copy,
                                    color: AppColors.grey,
                                    size: 20.sp,
                                  ),
                                ),
                                validator: _controller.validatePassword,
                              ),
                            ),
                            AppSpacing.vXxxl,
                            Obx(
                              () => AppPrimaryButton(
                                text: LK.signIn.tr,
                                onPressed: () => _controller.submit(
                                  formKey: formKey,
                                  mobile: mobileController.text,
                                  password: passwordController.text,
                                ),
                                isLoading: _controller.isFormLoading,
                              ),
                            ),
                            Obx(() {
                              final error = _controller.formError.value;
                              if (error == null) return SizedBox.shrink();
                              return Column(
                                children: [
                                  AppSpacing.vL,
                                  AppInlineError(message: error),
                                ],
                              );
                            }),
                          ],
                        ).paddingSymmetric(
                          horizontal: AppSpacing.xxxl,
                          vertical: 40.h,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
