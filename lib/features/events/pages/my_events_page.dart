import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/features/events/controllers/my_events_controller.dart';
import 'package:pscommunitymobileapp/features/events/pages/event_details_page.dart';

class MyEventsPage extends GetView<MyEventsController> {
  const MyEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: Column(
        children: [
          Divider(thickness: 1, color: AppColors.grey.shade100, height: 1),
          _buildCustomTabBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.hasError.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48.w,
                          color: AppColors.red,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : 'Failed to load registered events',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => controller.fetchRegisteredEvents(
                            isRefresh: true,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return TabBarView(
                controller: controller.tabController,
                children: [
                  _buildEventList(controller.upcomingEvents, 0),
                  _buildEventList(controller.ongoingEvents, 1),
                  _buildEventList(controller.pastEvents, 2),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;

      return Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            _buildTabItem(
              title: 'Upcoming',
              count: controller.upcomingCount.value,
              isSelected: selectedIndex == 0,
              onTap: () => controller.onTabChanged(0),
            ),
            SizedBox(width: 8.w),
            _buildTabItem(
              title: 'Ongoing',
              count: controller.ongoingCount.value,
              isSelected: selectedIndex == 1,
              onTap: () => controller.onTabChanged(1),
            ),
            SizedBox(width: 8.w),
            _buildTabItem(
              title: 'Past',
              count: controller.pastCount.value,
              isSelected: selectedIndex == 2,
              onTap: () => controller.onTabChanged(2),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE6F4EA) // Light mint green as in screenshot
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1E8E3E)
                      : AppColors.grey.shade600,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1E8E3E)
                      : AppColors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList(List<Items> events, int tabIndex) {
    if (events.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.fetchRegisteredEvents(isRefresh: true),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tabIndex == 0
                      ? Icons.event_available_rounded
                      : tabIndex == 1
                          ? Icons.event_note_rounded
                          : Icons.history_rounded,
                  size: 48.w,
                  color: AppColors.grey.shade300,
                ),
                SizedBox(height: 12.h),
                Text(
                  tabIndex == 0
                      ? 'No upcoming registered events'
                      : tabIndex == 1
                          ? 'No ongoing registered events'
                          : 'No past registered events',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchRegisteredEvents(isRefresh: true),
      color: AppColors.primary,
      child: ListView.separated(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        itemCount: events.length + (controller.isLoadingMore.value ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index == events.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          }
          final item = events[index];
          return _buildEventCard(item, tabIndex);
        },
      ),
    );
  }

  Widget _buildEventCard(Items item, int tabIndex) {
    final dateTimeStr = _formatDateTime(item);
    final statusNote = _getStatusNote(item, tabIndex);
    final statusBadge = item.registrationStatusName?.toLowerCase() ?? 'registered';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.eventId != null && item.eventId! > 0) {
            Get.to(() => EventDetailsPage(eventId: item.eventId!));
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey.shade200,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.eventName ?? '',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA), // light mint badge
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      statusBadge,
                      style: TextStyle(
                        color: const Color(0xFF1E8E3E),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (dateTimeStr.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  dateTimeStr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade700,
                    fontSize: 13.sp,
                  ),
                ),
              ],
              if ((item.registrationNumber ?? item.eventCode ?? '').isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  item.registrationNumber ?? item.eventCode ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
              if (statusNote.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  statusNote,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey.shade500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(RegisteredEventItem item) {
    final dateStr = item.registeredAt ?? item.createdAt;
    if (dateStr != null && dateStr.isNotEmpty) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        return DateFormat('d MMM yyyy, h:mm a').format(dt).toLowerCase();
      }
    }
    return '';
  }

  String _getStatusNote(Items item, int tabIndex) {
    if (item.cancelledAt != null ||
        (item.registrationStatusName ?? '').toLowerCase().contains('cancel')) {
      return item.cancellationReason ?? 'Registration cancelled';
    }
    if (tabIndex == 2 || (item.notes ?? '').toLowerCase().contains('over')) {
      return item.notes?.isNotEmpty == true ? item.notes! : 'Event is over';
    }
    if (tabIndex == 1) {
      return 'Event is currently ongoing';
    }
    return item.notes ?? '';
  }
}
