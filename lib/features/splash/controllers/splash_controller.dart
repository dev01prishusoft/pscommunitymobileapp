import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/services/push_notification_service.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static final _splashDuration = Duration(milliseconds: 2500);

  Timer? _navigationTimer;

  late final AnimationController _animController;
  late final Animation<double> scaleAnim;
  late final Animation<double> fadeAnim;

  @override
  void onInit() {
    super.onInit();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _animController.forward();
  }

  @override
  void onReady() {
    super.onReady();
    _scheduleNavigation();
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _scheduleNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(_splashDuration, _navigateToHome);
  }

  void _navigateToHome() {
    if (!isClosed) {
      final pushService = Get.isRegistered<PushNotificationService>()
          ? Get.find<PushNotificationService>()
          : null;

      if (pushService != null && pushService.hasInitialMessage) {
        Get.offNamed<void>(AppRouter.home);
        Future.delayed(const Duration(milliseconds: 300), () {
          pushService.handleInitialMessage();
        });
      } else {
        Get.offNamed<void>(AppRouter.home);
      }
    }
  }
}