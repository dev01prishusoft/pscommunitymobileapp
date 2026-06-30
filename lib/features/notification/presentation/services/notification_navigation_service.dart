import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

class NotificationNavigationService {
  Future<void> navigateToSource(String? pageSource) async {
    switch (pageSource?.toLowerCase()) {
      case 'home':
        await Get.offAllNamed<void>(AppRouter.home);
        break;
      case 'profile':
        await Get.toNamed<void>(AppRouter.memberProfile);
        break;
      case 'notification':
        // Already on the notifications page
        break;
      default:
        // Other pages like 'Events' are not implemented yet.
        // Fallback or do nothing.
        break;
    }
  }
}
