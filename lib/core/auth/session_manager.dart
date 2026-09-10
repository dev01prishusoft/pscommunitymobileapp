import 'dart:async';

import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';

class SessionManager extends GetxController {
  SessionManager(
    this._authState, {
    Duration timeoutDuration = const Duration(minutes: 15),
  }) : _timeoutDuration = timeoutDuration;

  final AuthState _authState;
  final Duration _timeoutDuration;
  Timer? _inactivityTimer;
  DateTime _lastInteraction = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    if (_authState.isAuthenticated.value) {
      _startTimer();
    }
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
    if (!_authState.isAuthenticated.value) return;

    _inactivityTimer = Timer(_timeoutDuration, _onTimeout);
  }

  void _stopTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void _onTimeout() {
    if (_authState.isAuthenticated.value) {
      _stopTimer();
      _authState.logoutAndRedirect();
      PSDelightToastBar(
        builder: (_) => ToastCard(
          title: LK.sessionExpired.tr,
          subtitle: LK.sessionExpiredBody.tr,
          isErrorMessage: true,
        ),
      ).show();
    }
  }

  void userInteracted() {
    if (!_authState.isAuthenticated.value) return;

    final now = DateTime.now();
    // Throttle timer resets to at most once per second to prevent high CPU overhead on continuous pointer move
    if (now.difference(_lastInteraction).inSeconds >= 1) {
      _lastInteraction = now;
      _startTimer();
    }
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }
}
