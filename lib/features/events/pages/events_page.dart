import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/features/events/controllers/events_controller.dart';
import 'package:pscommunitymobileapp/core/widgets/event_card.dart';
import 'package:pscommunitymobileapp/core/models/get_all_events.dart';
import 'package:pscommunitymobileapp/features/events/pages/event_scanner_page.dart';
import 'package:pscommunitymobileapp/features/events/repositories/event_attendance_repository_impl.dart';

class EventsPage extends GetView<EventsController> {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFabVisible = controller.isFabVisible.value;
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

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.scan_barcode_copy),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const _TokenInputDialog(),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.search_normal_copy),
                    onPressed: () {
                      controller.isSearchVisible.value = true;
                    },
                  ),
                ],
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
        floatingActionButton: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: isFabVisible ? MediaQuery.of(context).size.width - 32.w : 56,
          height: isFabVisible ? 52.h : 56,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed<void>(AppRouter.myEvents),
              borderRadius: BorderRadius.circular(isFabVisible ? 16 : 28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isFabVisible ? 16 : 28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: isFabVisible ? 12 : 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: isFabVisible
                      ? Row(
                          key: const ValueKey('expanded'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              color: AppColors.white,
                              size: 22,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'My Events',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Icon(
                          key: ValueKey('collapsed'),
                          Icons.event_available_rounded,
                          color: AppColors.white,
                          size: 24,
                        ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: isFabVisible
            ? FloatingActionButtonLocation.centerFloat
            : FloatingActionButtonLocation.endFloat,
      );
    });
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
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 10.h,
          bottom: 100.h,
        ),
        itemCount: events.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == events.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final String status = type == 1
              ? 'Upcoming'
              : type == 2
                  ? 'Ongoing'
                  : 'Past';
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: EventCard(
              event: events[index],
              eventStatus: status,
            ),
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

class _TokenInputDialog extends StatefulWidget {
  const _TokenInputDialog({Key? key}) : super(key: key);

  @override
  State<_TokenInputDialog> createState() => _TokenInputDialogState();
}

class _TokenInputDialogState extends State<_TokenInputDialog> {
  late final TextEditingController _tokenController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(
      text: EventAttendanceRepositoryImpl.globalCustomToken,
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _tokenController.text = data.text!.trim();
        _errorMessage = null;
      });
    }
  }

  void _onSave() {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid token to proceed';
      });
      return;
    }

    EventAttendanceRepositoryImpl.updateToken(token);
    Navigator.of(context).pop();
    Get.to(() => EventScannerPage(customToken: token));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.scan_barcode_copy,
                    color: AppColors.primary,
                    size: 22.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR Scanner Token',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Enter custom token to authorize scanner',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Custom Token',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _tokenController,
              maxLines: 4,
              minLines: 2,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.sp,
                color: AppColors.black,
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Paste or enter your custom token here...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey.shade400,
                  fontSize: 12.sp,
                ),
                contentPadding: EdgeInsets.all(12.w),
                fillColor: AppColors.grey.shade50,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: _errorMessage != null
                        ? AppColors.error
                        : AppColors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: _errorMessage != null
                        ? AppColors.error
                        : AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 6.h),
              Text(
                _errorMessage!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.error,
                  fontSize: 11.sp,
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: Icon(
                    Icons.paste_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Paste from clipboard',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_tokenController.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tokenController.clear();
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      'Clear',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: AppColors.grey.shade300),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
