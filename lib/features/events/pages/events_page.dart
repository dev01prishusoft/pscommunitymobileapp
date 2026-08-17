import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/features/events/controllers/events_controller.dart';
import 'package:pscommunitymobileapp/core/widgets/event_card.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';

class EventsPage extends GetView<EventsController> {
  const EventsPage({Key? key}) : super(key: key);

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
              hintText: 'Search events...',
              controller: controller.searchTextController,
              onChanged: (val) {
                controller.onSearchQueryChanged(val);
              },
            );
          }
          return Text(LK.events.tr);
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
      body: Column(
        children: [
          Divider(thickness: 1, color: AppColors.grey.shade100, height: 1),
          _buildCustomTabBar(),
          Expanded(
            child: Obx(() {
              return TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.tabController,
                children: [
                  _buildEventList(
                    controller.upcomingEvents,
                    controller.upcomingScrollController,
                    controller.isLoadingUpcoming.value,
                    controller.upcomingHasMore,
                    1,
                  ),
                  _buildEventList(
                    controller.ongoingEvents,
                    controller.ongoingScrollController,
                    controller.isLoadingOngoing.value,
                    controller.ongoingHasMore,
                    2,
                  ),
                  _buildEventList(
                    controller.pastEvents,
                    controller.pastScrollController,
                    controller.isLoadingPast.value,
                    controller.pastHasMore,
                    3,
                  ),
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
                  // Tab items
                  Row(
                    children: [
                      _buildCustomTabItem(
                        index: 0,
                        label: 'Upcoming',
                        count: '${controller.upcomingCount.value}',
                        isSelected: selectedIndex == 0,
                        defaultColor: AppColors.primary,
                      ),
                      _buildCustomTabItem(
                        index: 1,
                        label: 'Ongoing',
                        count: '${controller.ongoingCount.value}',
                        isSelected: selectedIndex == 1,
                        defaultColor: AppColors.green,
                      ),
                      _buildCustomTabItem(
                        index: 2,
                        label: 'Past',
                        count: '${controller.pastCount.value}',
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

  Widget _buildCustomTabItem({
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
          controller.tabController.animateTo(index);
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

  Widget _buildEventList(
    List<EventsData> events,
    ScrollController scrollController,
    bool isLoading,
    bool hasMore,
    int type,
  ) {
    Widget content;

    if (isLoading && events.isEmpty) {
      content = const Center(child: CircularProgressIndicator());
    } else if (events.isEmpty) {
      content = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: constraints.maxHeight,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64.w,
                  color: AppColors.grey.shade300,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No events found',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: events.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == events.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: EventCard(event: events[index]),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshTab(type),
      color: AppColors.primary,
      child: content,
    );
  }
}
