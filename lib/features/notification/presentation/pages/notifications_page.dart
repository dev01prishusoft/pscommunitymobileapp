import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_error_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_loading_indicator.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/controllers/notification_controller.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/widgets/notification_card.dart';

class NotificationsPage extends GetView<NotificationController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LK.notifications.tr, style: AppTextStyles.titleLarge),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: AppLoadingIndicator());
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.notifications.isEmpty) {
          return AppErrorState(
            errorMessage: controller.errorMessage.value,
            onRetry: controller.fetchNotifications,
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              LK.noNotificationsFound.tr,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          color: AppColors.primary,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                controller.fetchMoreNotifications();
              }
              return false;
            },
            child: ListView.builder(
              padding: AppSpacing.pM,
              itemCount:
                  controller.notifications.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: AppLoadingIndicator(size: 24)),
                  );
                }

                final notification = controller.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => controller.handleNotificationClick(notification),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
