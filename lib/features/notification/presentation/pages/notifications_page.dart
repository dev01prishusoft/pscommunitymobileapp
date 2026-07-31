import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_error_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_loading_indicator.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/controllers/notification_controller.dart';
import 'package:pscommunitymobileapp/features/notification/presentation/widgets/notification_card.dart';

class NotificationsPage extends GetView<NotificationController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(LK.notifications.tr),
          actions: [
            TextButton(
              onPressed: () {
                Get.dialog<void>(
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    elevation: 6,
                    backgroundColor: AppColors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 24.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete_forever_rounded,
                              color: AppColors.red,
                              size: 36.sp,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            LK.deleteAllNotification.tr,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            LK.deleteAllNotificationDesc.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back<void>(),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    side: BorderSide(
                                      color: AppColors.grey.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    LK.cancel.tr,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: AppPrimaryButton(
                                  text: LK.yes.tr,
                                  height: 48.h,
                                  color: AppColors.red,
                                  onPressed: () {
                                    Get.back<void>();
                                    controller.deleteNotification();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                "Clear All",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
                padding: EdgeInsets.only(top: 10.h, bottom: 60.h),
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
                  return Dismissible(
                    key: Key(notification.memberNotificationId.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      HapticFeedback.mediumImpact();
                      controller.deleteNotification(
                        notificationID: notification.memberNotificationId,
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.w),
                      margin: EdgeInsets.only(bottom: AppSpacing.sH),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            LK.delete.tr,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: NotificationCard(
                      notification: notification,
                      onTap: () =>
                          controller.handleNotificationClick(notification),
                    ),
                  ).paddingSymmetric(horizontal: 16.w);
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
