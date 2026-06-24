import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static final _splashDuration = Duration(milliseconds: 2500);

  Timer? _navigationTimer;

  late AnimationController animController;
  late Animation<double> scaleAnim;
  late Animation<double> fadeAnim;

  @override
  void onInit() {
    super.onInit();
    animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeOutBack),
    );
    fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    animController.forward();
  }

  @override
  void onReady() {
    super.onReady();
    _scheduleNavigation();
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    animController.dispose();
    super.onClose();
  }

  void _scheduleNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(_splashDuration, _navigateToHome);
  }

  void _navigateToHome() {
    if (!isClosed) {
      Get.offNamed<void>(AppRouter.home);
    }
  }
}
