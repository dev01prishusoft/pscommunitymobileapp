import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/models/registered_events_model.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/events/controllers/my_events_controller.dart';
import 'package:pscommunitymobileapp/features/events/pages/my_event_details_page.dart';

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
      if (widget.targetStatus != null) {
        final st = widget.targetStatus!.toLowerCase();
        if (st.contains('ongo')) {
          controller.selectedTabIndex.value = 1;
        } else if (st.contains('past')) {
          controller.selectedTabIndex.value = 2;
        } else {
          controller.selectedTabIndex.value = 0;
        }
      }
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
        title: Obx(() {
          if (controller.isSearchVisible.value) {
            return CupertinoSearchbar(
              onTapSuffix: () {
                controller.searchTextController.clear();
                controller.onSearchQueryChanged('');
                FocusManager.instance.primaryFocus?.unfocus();
                controller.isSearchVisible.value = false;
              },
              hintText: LK.my_events_search_hint.tr,
              controller: controller.searchTextController,
              onChanged: (val) {
                controller.onSearchQueryChanged(val);
              },
            );
          }
          return Text(LK.events_my_events_btn.tr);
        }),
        actions: [
          Obx(() {
            if (controller.isSearchVisible.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Iconsax.search_normal_copy),
              onPressed: () {
                controller.isSearchVisible.value = true;
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allItems.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.hasError.value && controller.allItems.isEmpty) {
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
                        : LK.my_events_load_failed.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        controller.fetchRegisteredEvents(isRefresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      LK.retry.tr,
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
            _buildCustomTabBar(),

            if (isFiltered) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
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
                            controller.targetEventName.value ??
                                LK.my_events_selected_event.tr,
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
                                  '${LK.event_details_status.tr}: ',
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
                        LK.my_events_show_all.tr,
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
                                controller.searchQuery.value.trim().isNotEmpty
                                    ? LK.my_events_no_match.tr
                                    : (isFiltered
                                          ? (controller.targetEventName.value !=
                                                    null
                                                ? LK.my_events_no_match.tr
                                                : LK.my_events_no_match.tr)
                                          : _getEmptyMessage(
                                              controller.selectedTabIndex.value,
                                            )),
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
                                    LK.my_events_show_all.tr,
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
                        itemCount:
                            displayedList.length +
                            (controller.isLoadingMore.value ? 1 : 0),
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          if (index == displayedList.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
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

  Widget _buildCustomTabBar() {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final double tabWidth = totalWidth / 3;

            return Container(
              height: 54.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1.w,
                ),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: selectedIndex * tabWidth + 3.w,
                    top: 3.h,
                    bottom: 3.h,
                    width: tabWidth - 6.w,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildTabItem(
                        index: 0,
                        label: LK.events_tab_upcoming.tr,
                        count: '${controller.upcomingCount}',
                        isSelected: selectedIndex == 0,
                        defaultColor: AppColors.primary,
                      ),
                      _buildTabItem(
                        index: 1,
                        label: LK.events_tab_ongoing.tr,
                        count: '${controller.ongoingCount}',
                        isSelected: selectedIndex == 1,
                        defaultColor: AppColors.green,
                      ),
                      _buildTabItem(
                        index: 2,
                        label: LK.events_tab_past.tr,
                        count: '${controller.pastCount}',
                        isSelected: selectedIndex == 2,
                        defaultColor: AppColors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required String count,
    required bool isSelected,
    required Color defaultColor,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller.selectedTabIndex.value = index;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : defaultColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.9)
                    : AppColors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return LK.no.tr + "" + LK.events_tab_upcoming.tr + "" + LK.event_register_event_not_found_suffix.tr;
      case 1:
        return LK.no.tr + "" + LK.events_tab_ongoing.tr + "" + LK.event_register_event_not_found_suffix.tr;
      case 2:
        return LK.no.tr + "" + LK.events_tab_past.tr + "" + LK.event_register_event_not_found_suffix.tr;
      default:
        return LK.my_events_no_match.tr;
    }
  }

  (Color textColor, Color bgColor) _getStatusBadgeColors(String status) {
    final s = status.toLowerCase();
    if (s.contains('cancel')) {
      return (AppColors.error, AppColors.errorLight);
    } else if (s.contains('register')) {
      return (AppColors.success, AppColors.successLight);
    } else {
      return (AppColors.neutral, AppColors.neutralLight);
    }
  }

  Widget _buildEventCard(RegisteredEventItem item, {String? statusOverride}) {
    final dateTimeStr = _formatDateTime(item);
    final statusNote = _getStatusNote(item);
    final statusBadge =
        item.registrationStatusName?.toLowerCase() ?? 'registered';
    final (badgeTextColor, badgeBgColor) = _getStatusBadgeColors(statusBadge);
    final venue = item.venueName?.toString() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await Get.to(
            () => MyEventDetailsPage(
              eventRegistrationId:
                  item.eventRegistrationId ?? item.eventId ?? 0,
              initialItem: item,
            ),
          );
          if (result == true) {
            controller.fetchRegisteredEvents(isRefresh: true);
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.grey.shade200, width: 1.w),
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
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      statusBadge.toUpperCase(),
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 10.sp,
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

    switch (status.toLowerCase()) {
      case 'ongoing':
        textColor = AppColors.warning;
        break;
      case 'past':
        textColor = AppColors.neutral;
        break;
      case 'upcoming':
      default:
        textColor = AppColors.info;
        break;
    }

    return Text(
      status,
      style: TextStyle(
        color: textColor,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
    );
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
      return item.cancellationReason?.toString() ??
          LK.my_events_note_cancelled.tr;
    }
    if ((item.notes ?? '').toLowerCase().contains('over')) {
      return item.notes?.isNotEmpty == true
          ? item.notes!
          : LK.my_events_note_over.tr;
    }
    return item.notes ?? '';
  }
}
