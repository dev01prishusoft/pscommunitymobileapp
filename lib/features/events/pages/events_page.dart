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
import 'package:pscommunitymobileapp/core/models/event_model.dart';

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
                controller.searchQuery.value = '';
                FocusManager.instance.primaryFocus?.unfocus();
                controller.isSearchVisible.value = false;
              },
              hintText: 'Search events...',
              controller: controller.searchTextController,
              onChanged: (val) {
                if (val.isEmpty) {
                  controller.searchTextController.clear();
                  controller.searchQuery.value = '';
                  FocusManager.instance.primaryFocus?.unfocus();
                  controller.isSearchVisible.value = false;
                } else {
                  controller.searchQuery.value = val;
                }
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
              if (controller.allEvents.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return TabBarView(
                controller: controller.tabController,
                children: [
                  _buildEventList(controller.upcomingEvents),
                  _buildEventList(controller.ongoingEvents),
                  _buildEventList(controller.pastEvents),
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
                        count: '${controller.upcomingEvents.length}',
                        isSelected: selectedIndex == 0,
                        defaultColor: AppColors.primary,
                      ),
                      _buildCustomTabItem(
                        index: 1,
                        label: 'Ongoing',
                        count: '${controller.ongoingEvents.length}',
                        isSelected: selectedIndex == 1,
                        defaultColor: AppColors.green,
                      ),
                      _buildCustomTabItem(
                        index: 2,
                        label: 'Past',
                        count: '${controller.pastEvents.length}',
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

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64.w, color: AppColors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'No events found',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: EventCard(event: events[index]),
        );
      },
    );
  }
}
