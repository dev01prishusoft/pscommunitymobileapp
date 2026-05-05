import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // If UI Review Mode is enabled, bypass auth check
    if (kUiReviewMode) return null;

    final controller = Get.find<LoginController>();
    
    // Check if user is logged in (simplified check for mock/UI review context)
    // In a real app, you'd check if tokens are present and valid
    if (controller.tokens.value == null) {
      return const RouteSettings(name: AppRouter.login);
    }
    
    return null;
  }
}
