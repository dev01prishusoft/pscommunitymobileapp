import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/widgets/app_error_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_loading_indicator.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/controllers/notification_controller.dart';

class NotificationsPage extends GetView<NotificationController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.navyBlue),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navyBlue),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: AppLoadingIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.notifications.isEmpty) {
          return AppErrorState(
            errorMessage: controller.errorMessage.value,
            onRetry: controller.fetchNotifications,
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications found',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          color: AppColors.navyBlue,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                controller.fetchMoreNotifications();
              }
              return false;
            },
            child: ListView.builder(
              padding: AppSpacing.pM,
              itemCount: controller.notifications.length + (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: AppLoadingIndicator(size: 24)),
                  );
                }
                
                final notification = controller.notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => controller.handleNotificationClick(notification),
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      contentPadding: AppSpacing.pM,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.lightBlue,
                        child: Icon(
                          Icons.notifications_active,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      title: Text(
                        notification.message,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.navyBlue,
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _formatDate(notification.sendTime),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                        ),
                      ),
                      trailing: !notification.isRead
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
