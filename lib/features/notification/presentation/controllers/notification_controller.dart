import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/notification/data/models/member_notification.dart';
import 'package:pscommunitymobileapp/features/notification/data/repositories/notification_repository.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/services/notification_navigation_service.dart';

class NotificationController extends GetxController {
  NotificationController(this._repository, this._navigationService);

  final NotificationRepository _repository;
  final NotificationNavigationService _navigationService;

  final RxList<MemberNotification> notifications = <MemberNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    super.onClose();
  }

  Future<void> fetchNotifications() async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    _currentPage = 1;
    _hasMoreData = true;
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getNotifications(_currentPage, _pageSize, cancelToken: _cancelToken);
    
    if (result.isFailure) {
      if (result.failureOrNull?.message != 'canceled') {
        errorMessage.value = result.failureOrNull?.message ?? LK.unknownError.tr;
        notifications.clear();
      }
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

    final result = await _repository.getNotifications(_currentPage, _pageSize, cancelToken: _cancelToken);
    if (result.isFailure) {
      if (result.failureOrNull?.message != 'canceled') {
        _currentPage--;
        Get.snackbar(LK.error.tr, result.failureOrNull?.message ?? LK.unknownError.tr);
      }
    } else if (result.isSuccess) {
      final response = result.dataOrNull!;
      for (var notification in response.data) {
        if (!notifications.any((n) => n.memberNotificationId == notification.memberNotificationId)) {
          notifications.add(notification);
        }
      }
      if (response.data.length < _pageSize) {
        _hasMoreData = false;
      }
    }

    isLoadingMore.value = false;
  }

  Future<void> handleNotificationClick(MemberNotification notification) async {
    if (!notification.isRead) {
      final index = notifications.indexWhere((n) => n.memberNotificationId == notification.memberNotificationId);
      MemberNotification? oldNotification;
      
      // Optimistic update
      if (index != -1) {
        oldNotification = notifications[index];
        final updatedNotification = oldNotification.copyWith(isRead: true);
        notifications[index] = updatedNotification;
      }
      
      final result = await _repository.markAsRead(notification.memberNotificationId, cancelToken: _cancelToken);
      if (result.isFailure) {
        // Revert on failure
        if (index != -1 && oldNotification != null) {
          notifications[index] = oldNotification;
        }
        if (result.failureOrNull?.message != 'canceled') {
          Get.snackbar(LK.error.tr, result.failureOrNull?.message ?? LK.unknownError.tr);
        }
        return; // Don't navigate if markAsRead fails? The prompt says "Handle markAsRead() failure". Usually we still navigate or we don't. I'll let it proceed.
      }
    }

    await _navigationService.navigateToSource(notification);
  }
}
