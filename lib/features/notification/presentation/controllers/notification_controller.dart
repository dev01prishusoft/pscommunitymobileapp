import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';
import 'package:pscommunitymobileapp/features/notification/data/repositories/notification_repository.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

class NotificationController extends GetxController {
  NotificationController(this._repository);

  final NotificationRepository _repository;

  final RxList<MemberNotification> notifications = <MemberNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _currentPage = 1;
    _hasMoreData = true;
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getNotifications(_currentPage, _pageSize);
    if (result.isFailure) {
      errorMessage.value = result.failureOrNull?.message ?? 'Unknown error';
      notifications.clear();
    } else if (result.isSuccess) {
      final response = result.dataOrNull!;
      notifications.assignAll(response.data);
      if (response.data.length < _pageSize) {
        _hasMoreData = false;
      }
    }

    isLoading.value = false;
  }

  Future<void> fetchMoreNotifications() async {
    if (!_hasMoreData || isLoadingMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    final result = await _repository.getNotifications(_currentPage, _pageSize);
    if (result.isFailure) {
      _currentPage--;
    } else if (result.isSuccess) {
      final response = result.dataOrNull!;
      notifications.addAll(response.data);
      if (response.data.length < _pageSize) {
        _hasMoreData = false;
      }
    }

    isLoadingMore.value = false;
  }

  Future<void> handleNotificationClick(MemberNotification notification) async {
    if (!notification.isRead) {
      final index = notifications.indexWhere((n) => n.memberNotificationId == notification.memberNotificationId);
      if (index != -1) {
        final updatedNotification = notifications[index].copyWith(isRead: true);
        notifications[index] = updatedNotification;
      }
      _repository.markAsRead(notification.memberNotificationId);
    }

    switch (notification.pageSource?.toLowerCase()) {
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
