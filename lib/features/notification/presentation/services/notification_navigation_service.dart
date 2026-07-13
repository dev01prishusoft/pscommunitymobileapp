import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';

class NotificationNavigationService {
  Future<void> navigateToSource(MemberNotification notification) async {
    final pageText = (notification.pageText ?? notification.pageSource ?? '').toString().trim().toLowerCase();

    switch (pageText) {
      case 'family':
        await Get.toNamed<void>(AppRouter.familyAreas);
        break;
      case 'find member':
        await Get.toNamed<void>(AppRouter.findMember);
        break;
      case 'committee':
        await Get.toNamed<void>(AppRouter.committees);
        break;
      case 'payment':
        await Get.toNamed<void>(AppRouter.payments);
        break;
      case 'occupation directory':
        await Get.toNamed<void>(AppRouter.occupationDirectory);
        break;
      case 'matrimonial':
        await Get.toNamed<void>(AppRouter.marriage);
        break;
      case 'share app':
        await Get.toNamed<void>(AppRouter.shareApp);
        break;
      case 'samaj profile':
        await Get.toNamed<void>(AppRouter.bankDetails);
        break;
      case 'support':
        await Get.toNamed<void>(AppRouter.customerSupport);
        break;
      case 'notification':
        break;
      case 'home':
        await Get.offAllNamed<void>(AppRouter.home);
        break;
      case 'profile':
        await Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': notification.memberId},
        );
        break;
      default:
        break;
    }
  }
}
