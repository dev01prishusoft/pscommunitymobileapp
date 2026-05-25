import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/constants/app_config.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (kUiReviewMode) return null;

    final auth = Get.find<AuthState>();

    if (!auth.isAuthenticated.value) {
      return RouteSettings(name: AppRouter.login);
    }

    return null;
  }
}
