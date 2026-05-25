import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';

class SessionManager extends GetxController {
  SessionManager(this._authState);
  
  final AuthState _authState;
  Timer? _inactivityTimer;
  final Duration _timeoutDuration = const Duration(minutes: 15);

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    ever(_authState.isAuthenticated, (bool isAuthenticated) {
      if (isAuthenticated) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });
  }

  void _startTimer() {
    _stopTimer();
    if (_authState.isAuthenticated.value) {
      _inactivityTimer = Timer(_timeoutDuration, _onTimeout);
    }
  }

  void _stopTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void _onTimeout() {
    if (_authState.isAuthenticated.value) {
      _authState.logoutAndRedirect();
      Get.snackbar(
        'Session Expired',
        'You have been logged out due to inactivity.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void userInteracted() {
    _startTimer();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }
}
