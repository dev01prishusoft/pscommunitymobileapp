import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/features/family/presentation/widgets/member_tile.dart';

class FamilyMembersListPage extends StatefulWidget {
  const FamilyMembersListPage({super.key});

  @override
  State<FamilyMembersListPage> createState() => _FamilyMembersListPageState();
}

class _FamilyMembersListPageState extends State<FamilyMembersListPage> {
  final FamilyController _controller = Get.find<FamilyController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late int _areaId;
  late String _areaName;
  late int _membersCount;
  late int _familiesCount;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _areaId = args['areaId'] as int? ?? 0;
    _areaName = args['areaName'] as String? ?? '';
    _membersCount = args['membersCount'] as int? ?? 0;
    _familiesCount = args['familiesCount'] as int? ?? 0;

    _controller.memberSearchQuery.value = '';
    _controller.loadFamilies(_areaId);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _controller.loadFamilies(_areaId, isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back<void>(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _areaName,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '$_membersCount ${_membersCount == 1 ? LK.member.tr : LK.membersCount.tr}  |  $_familiesCount ${LK.familiesCount.tr}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: LK.searchByNameHint.tr,
                prefixIcon: const Icon(Iconsax.search_normal_copy),
                suffixIcon: Obx(
                  () => _controller.memberSearchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: LK.clearAll.tr,
                          onPressed: () {
                            _searchController.clear();
                            _controller.memberSearchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              onChanged: (value) {
                _controller.memberSearchQuery.value = value;
              },
            ),
          ),

          Expanded(
            child: Obx(
              () => AppStateView(
                state: _controller.familyListState.value,
                onRetry: () => _controller.loadFamilies(_areaId),
                child: _controller.filteredFamilies.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.w),
                                    child: AppEmptyState(
                                      icon: Icons.search_off_rounded,
                                      secondaryIcon: Iconsax.search_normal_copy,
                                      title: LK.noResultsFound.tr,
                                      subtitle:
                                          LK.trySelectingDifferentFilters.tr,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        itemCount:
                            _controller.filteredFamilies.length +
                            (_controller.hasMoreFamilies.value ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          if (index == _controller.filteredFamilies.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: const CircularProgressIndicator(),
                              ),
                            );
                          }
                          final family = _controller.filteredFamilies[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: AppColors.grey.withValues(alpha: 0.15),
                                width: 1.2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(
                                    alpha: 0.03,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.04,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18.r),
                                      topRight: Radius.circular(18.r),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.people_alt_rounded,
                                        color: AppColors.primary,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          family.familyName,
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.secondary,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Text(
                                          '${family.members.length} ${family.members.length == 1 ? "Member" : "Members"}',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1.h,
                                  color: AppColors.grey.withValues(alpha: 0.15),
                                ),
                                ...family.members.asMap().entries.map((entry) {
                                  return MemberTile(
                                    member: entry.value,
                                    showDivider: entry.key > 0,
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
