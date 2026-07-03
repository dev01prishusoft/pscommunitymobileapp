import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';

class NotificationNavigationService {
  Future<void> navigateToSource(MemberNotification notification) async {
    switch (notification.pageSource?.toLowerCase()) {
      case 'home':
        await Get.offAllNamed<void>(AppRouter.home);
        break;
      case 'profile':
        await Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': notification.memberId},
        );
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
