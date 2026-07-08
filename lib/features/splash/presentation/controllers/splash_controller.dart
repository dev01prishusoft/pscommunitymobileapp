import 'dart:async';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/services/push_notification_service.dart';

class SplashController extends GetxController {
  static final _splashDuration = Duration(milliseconds: 2500);

  Timer? _navigationTimer;

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

  void _scheduleNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(_splashDuration, _navigateToHome);
  }

  void _navigateToHome() {
    if (!isClosed) {
      if (Get.isRegistered<PushNotificationService>() && Get.find<PushNotificationService>().hasInitialMessage) {
        Get.find<PushNotificationService>().handleInitialMessage();
      } else {
        Get.offNamed<void>(AppRouter.home);
      }
    }
  }
}
