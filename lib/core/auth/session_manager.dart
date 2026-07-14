import 'dart:async';

import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';

class SessionManager extends GetxController {
  SessionManager(this._authState);

  final AuthState _authState;
  Timer? _inactivityTimer;

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

  void _startTimer() {}

  void _stopTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
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
