import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/features/events/controllers/my_events_controller.dart';
import 'package:pscommunitymobileapp/features/events/pages/event_details_page.dart';

class MyEventsPage extends StatefulWidget {
  final int? targetEventId;
  final String? targetEventName;
  final String? targetStatus;

  const MyEventsPage({
    Key? key,
    this.targetEventId,
    this.targetEventName,
    this.targetStatus,
  }) : super(key: key);

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  late final MyEventsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MyEventsController>();
    if (widget.targetEventId != null) {
      controller.setFilter(
        eventId: widget.targetEventId,
        eventName: widget.targetEventName,
        status: widget.targetStatus,
      );
    } else {
      controller.clearFilter();
    }
  }

  @override
  void dispose() {
    controller.clearFilter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: Obx(() {
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

        final displayedList = controller.displayedEvents;
        final bool isFiltered = controller.targetEventId.value != null;

        return Column(
          children: [
            // Filter banner when redirected from a specific event
            if (isFiltered) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 20.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.targetEventName.value ?? 'Selected Event',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (controller.targetStatus.value != null) ...[
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Text(
                                  'Status: ',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.grey.shade600,
                                  ),
                                ),
                                _buildStatusChip(
                                  controller.targetStatus.value!,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    TextButton(
                      onPressed: () => controller.clearFilter(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        backgroundColor: AppColors.white,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Show All',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Expanded(
              child: displayedList.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () =>
                          controller.fetchRegisteredEvents(isRefresh: true),
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: 450.h,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                size: 56.w,
                                color: AppColors.grey.shade300,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                isFiltered
                                    ? 'Registration for "${controller.targetEventName.value ?? 'this event'}" was not found in list'
                                    : 'No registered events found',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey.shade500,
                                  fontSize: 15.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isFiltered) ...[
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: () => controller.clearFilter(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    'View All Registered Events',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          controller.fetchRegisteredEvents(isRefresh: true),
                      color: AppColors.primary,
                      child: ListView.separated(
                        controller: controller.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        itemCount: displayedList.length +
                            (!isFiltered && controller.isLoadingMore.value
                                ? 1
                                : 0),
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          if (index == displayedList.length) {
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
                          final item = displayedList[index];
                          return _buildEventCard(
                            item,
                            statusOverride: isFiltered
                                ? controller.targetStatus.value
                                : null,
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEventCard(RegisteredEventItem item, {String? statusOverride}) {
    final dateTimeStr = _formatDateTime(item);
    final statusNote = _getStatusNote(item);
    final statusBadge =
        item.registrationStatusName?.toLowerCase() ?? 'registered';
    final venue = item.venueName?.toString() ?? '';
    final timingStatus = _getEventTimingStatus(item, statusOverride);

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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timing status badge (Upcoming, Ongoing, Past)
                      _buildStatusChip(timingStatus),
                      SizedBox(width: 6.w),
                      // Registered status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          statusBadge,
                          style: TextStyle(
                            color: const Color(0xFF1E8E3E),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (item.eventId != null && item.eventId! > 0) ...[
                SizedBox(height: 4.h),
                Text(
                  'Event ID: #${item.eventId}',
                  style: TextStyle(
                    color: AppColors.grey.shade500,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
              if (venue.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  venue,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.shade700,
                    fontSize: 13.sp,
                  ),
                ),
              ],
              if ((item.registrationNumber ?? item.eventCode ?? '')
                  .isNotEmpty) ...[
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

  Widget _buildStatusChip(String status) {
    Color textColor;
    Color bgColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'ongoing':
        textColor = const Color(0xFFE37400);
        bgColor = const Color(0xFFFEF7E0);
        icon = Icons.play_circle_fill_rounded;
        break;
      case 'past':
        textColor = const Color(0xFF5F6368);
        bgColor = const Color(0xFFF1F3F4);
        icon = Icons.history_rounded;
        break;
      case 'upcoming':
      default:
        textColor = const Color(0xFF1A73E8);
        bgColor = const Color(0xFFE8F0FE);
        icon = Icons.upcoming_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: textColor),
          SizedBox(width: 3.w),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTimingStatus(
    RegisteredEventItem item,
    String? overrideStatus,
  ) {
    if (overrideStatus != null && overrideStatus.isNotEmpty) {
      return overrideStatus;
    }

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (item.eventStartDateTime != null &&
        item.eventStartDateTime!.isNotEmpty) {
      start = DateTime.tryParse(item.eventStartDateTime!);
    }
    if (item.eventEndDateTime != null && item.eventEndDateTime!.isNotEmpty) {
      end = DateTime.tryParse(item.eventEndDateTime!);
    }

    if (start != null) {
      if (end != null) {
        if (now.isBefore(start)) return 'Upcoming';
        if (now.isAfter(end)) return 'Past';
        return 'Ongoing';
      } else {
        if (now.year == start.year &&
            now.month == start.month &&
            now.day == start.day) {
          return 'Ongoing';
        } else if (now.isAfter(start)) {
          return 'Past';
        } else {
          return 'Upcoming';
        }
      }
    }

    if ((item.notes ?? '').toLowerCase().contains('over') ||
        (item.registrationStatusName ?? '').toLowerCase().contains('cancel')) {
      return 'Past';
    }

    return 'Upcoming';
  }

  String _formatDateTime(RegisteredEventItem item) {
    if (item.eventStartDateTime != null &&
        item.eventStartDateTime!.isNotEmpty) {
      final start = DateTime.tryParse(item.eventStartDateTime!);
      final end = item.eventEndDateTime != null
          ? DateTime.tryParse(item.eventEndDateTime!)
          : null;

      if (start != null) {
        final dateStr = DateFormat('d MMM yyyy').format(start);
        final startTimeStr = DateFormat('h:mm a').format(start).toLowerCase();
        if (end != null) {
          final endTimeStr = DateFormat('h:mm a').format(end).toLowerCase();
          return '$dateStr, $startTimeStr to $endTimeStr';
        }
        return '$dateStr, $startTimeStr';
      }
    }

    if (item.timePeriod != null && item.timePeriod.toString().isNotEmpty) {
      return item.timePeriod.toString();
    }

    final dateStr = item.registeredAt ?? item.createdAt;
    if (dateStr != null && dateStr.isNotEmpty) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        return DateFormat('d MMM yyyy, h:mm a').format(dt).toLowerCase();
      }
    }
    return '';
  }

  String _getStatusNote(RegisteredEventItem item) {
    if (item.cancelledAt != null ||
        (item.registrationStatusName ?? '').toLowerCase().contains('cancel')) {
      return item.cancellationReason?.toString() ?? 'Registration cancelled';
    }
    if ((item.notes ?? '').toLowerCase().contains('over')) {
      return item.notes?.isNotEmpty == true ? item.notes! : 'Event is over';
    }
    return item.notes ?? '';
  }
}
