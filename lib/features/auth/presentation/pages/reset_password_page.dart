import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/reset_password_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily register the controller if not already present
    if (!Get.isRegistered<ResetPasswordController>()) {
      Get.put(ResetPasswordController());
    }
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

      if (success && context.mounted) {
        Get.offNamed(AppRouter.postLoginSplash);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Shapes
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFFFF), AppColors.accent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
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
                              'Reset Password'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // New Password Field
                            Text(
                              'New Password'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                               controller: newPasswordController,
                               hint: '........'.tr,
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
                                  return 'Please enter new password'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password Field
                            Text(
                              'Confirm New Password'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                               controller: confirmPasswordController,
                               hint: '........'.tr,
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
                                  return 'Please enter new password'.tr;
                                }
                                 if (value != newPasswordController.text) {
                                  return 'Passwords do not match'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Update Password Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                               child: ElevatedButton(
                                 onPressed: controller.isLoading.value ? null : submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                 child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Update Password'.tr,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: AppColors.foreground,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.mutedForeground),
        prefixIcon: Icon(icon, color: AppColors.mutedForeground),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.muted.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.destructive,
            width: 1.5,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
