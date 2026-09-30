import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';

enum NetworkErrorType {
  noInternet,
  serverDown,
  timeout,
}

class NetworkErrorArgs {
  final NetworkErrorType type;
  final String? customTitle;
  final String? customMessage;
  final Future<bool> Function()? onRetry;
  final bool canGoBack;

  NetworkErrorArgs({
    required this.type,
    this.customTitle,
    this.customMessage,
    this.onRetry,
    this.canGoBack = true,
  });
}

class GlobalNetworkErrorService extends GetxService {
  static GlobalNetworkErrorService get to =>
      Get.find<GlobalNetworkErrorService>();

  final ConnectivityService _connectivityService;
  GlobalNetworkErrorService(this._connectivityService);

  final RxBool isErrorScreenOpen = false.obs;
  final Rx<NetworkErrorType> currentErrorType = NetworkErrorType.serverDown.obs;
  final RxString currentErrorMessage = ''.obs;
  final RxBool isCheckingConnection = false.obs;

  Future<bool> Function()? _currentRetryCallback;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DateTime? _lastErrorOpenedTime;

  @override
  void onInit() {
    super.onInit();
    _listenToConnectivityChanges();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivityService.onChange.listen(
      (results) async {
        final hasLocalNetwork = results.any((r) => r != ConnectivityResult.none);

        if (isErrorScreenOpen.value && hasLocalNetwork) {
          // Network interface came back up; wait briefly for link stability
          await Future<void>.delayed(const Duration(milliseconds: 1200));
          if (!isErrorScreenOpen.value) return;

          final serverUp = await _connectivityService.isServerReachable();
          if (serverUp) {
            await autoRecover();
          } else {
            // Local network is alive, but remote server is down
            currentErrorType.value = NetworkErrorType.serverDown;
          }
        } else if (!hasLocalNetwork && !isErrorScreenOpen.value) {
          handleNetworkError(type: NetworkErrorType.noInternet);
        }
      },
    );
  }

  void handleNetworkError({
    required NetworkErrorType type,
    String? message,
    Future<bool> Function()? onRetry,
  }) {
    if (isErrorScreenOpen.value) {
      currentErrorType.value = type;
      if (message != null && message.isNotEmpty) {
        currentErrorMessage.value = message;
      }
      if (onRetry != null) {
        _currentRetryCallback = onRetry;
      }
      return;
    }

    final now = DateTime.now();
    if (_lastErrorOpenedTime != null &&
        now.difference(_lastErrorOpenedTime!) < const Duration(milliseconds: 1500)) {
      return;
    }
    _lastErrorOpenedTime = now;

    isErrorScreenOpen.value = true;
    currentErrorType.value = type;
    currentErrorMessage.value = message ?? '';
    _currentRetryCallback = onRetry;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) {
        isErrorScreenOpen.value = false;
        return;
      }

      final canPop = Navigator.of(Get.context!).canPop();

      Get.toNamed<void>(
        AppRouter.networkError,
        arguments: NetworkErrorArgs(
          type: type,
          customMessage: message,
          onRetry: onRetry,
          canGoBack: canPop,
        ),
      )?.then((_) {
        isErrorScreenOpen.value = false;
        _currentRetryCallback = null;
      });
    });
  }

  Future<bool> testAndRecover() async {
    if (isCheckingConnection.value) return false;
    isCheckingConnection.value = true;

    try {
      final hasNet = await _connectivityService.hasConnection();
      if (!hasNet) {
        currentErrorType.value = NetworkErrorType.noInternet;
        _showToast(LK.noInternetTitle.tr, isError: true);
        return false;
      }

      final isServerUp = await _connectivityService.isServerReachable();
      if (!isServerUp) {
        currentErrorType.value = NetworkErrorType.serverDown;
        _showToast(LK.serverStillUnreachable.tr, isError: true);
        return false;
      }

      if (_currentRetryCallback != null) {
        final success = await _currentRetryCallback!();
        if (!success) {
          _showToast(LK.serverStillUnreachable.tr, isError: true);
          return false;
        }
      }

      dismiss();
      _showToast(LK.connectionRestored.tr, isError: false);
      return true;
    } catch (_) {
      _showToast(LK.serverStillUnreachable.tr, isError: true);
      return false;
    } finally {
      isCheckingConnection.value = false;
    }
  }

  Future<void> autoRecover() async {
    if (isCheckingConnection.value) return;
    isCheckingConnection.value = true;
    try {
      if (_currentRetryCallback != null) {
        await _currentRetryCallback!();
      }
      dismiss();
      _showToast(LK.connectionRestored.tr, isError: false);
    } catch (_) {
      // Auto recovery will retry on next connectivity event or user action
    } finally {
      isCheckingConnection.value = false;
    }
  }

  void dismiss() {
    if (isErrorScreenOpen.value) {
      isErrorScreenOpen.value = false;
      _currentRetryCallback = null;
      if (Get.context != null && Navigator.of(Get.context!).canPop()) {
        Get.back<void>();
      } else {
        final authState = Get.isRegistered<AuthState>() ? Get.find<AuthState>() : null;
        final initialRoute = (authState?.isAuthenticated.value ?? false)
            ? AppRouter.home
            : AppRouter.login;
        Get.offAllNamed<void>(initialRoute);
      }
    }
  }

  void _showToast(String message, {required bool isError}) {
    if (Get.context == null) return;
    PSDelightToastBar(
      snackbarDuration: const Duration(seconds: 3),
      builder: (context) => ToastCard(
        title: message,
        leading: isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
        isErrorMessage: isError,
      ),
    ).show();
  }
}
