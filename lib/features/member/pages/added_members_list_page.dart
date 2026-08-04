import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/cupertino_searchbar.dart';
import 'package:pscommunitymobileapp/features/member/controllers/added_members_controller.dart';
import 'package:pscommunitymobileapp/core/widgets/added_member_card.dart';

class AddedMembersListPage extends StatefulWidget {
  const AddedMembersListPage({super.key});

  @override
  State<AddedMembersListPage> createState() => _AddedMembersListPageState();
}

class _AddedMembersListPageState extends State<AddedMembersListPage> {
  final AddedMembersController _controller = Get.put(AddedMembersController());
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _controller.fetchMembers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    Get.delete<AddedMembersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: _isSearchVisible
              ? CupertinoSearchbar(
                onTapSuffix: () {
                      _searchController.clear();
                      _controller.onSearchChanged('');
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        _isSearchVisible = false;
                      });
                    },
                  hintText: LK.searchByNameAndMnoAndMID.tr,
                  controller: _searchController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _searchController.clear();
                      _controller.onSearchChanged('');
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        _isSearchVisible = false;
                      });
                    } else {
                      _controller.onSearchChanged(value);
                    }
                  },
                )
              : Text(LK.addedMembers.tr),
          actions: [
            if (!_isSearchVisible)
              IconButton(
                icon: const Icon(Iconsax.search_normal_copy),
                onPressed: () {
                  setState(() {
                    _isSearchVisible = true;
                  });
                },
              ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.verticalSpace,
            _buildStatsPanel(),
            10.verticalSpace,
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value &&
                    _controller.members.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.filteredMembers.isEmpty &&
                    !_controller.isLoading.value) {
                  return RefreshIndicator(
                    onRefresh: () async => _controller.refreshMembers(),
                    color: AppColors.primary,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: AppEmptyState(
                                icon: Icons.search_off_rounded,
                                secondaryIcon: Icons.search_rounded,
                                title: LK.noResultsFound.tr,
                                subtitle: LK.trySelectingDifferentFilters.tr,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _controller.refreshMembers(),
                  color: AppColors.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 8.h,
                      bottom: 80.h,
                    ),
                    itemCount:
                        _controller.filteredMembers.length +
                        (_controller.hasMore.value &&
                                _controller.isLoading.value
                            ? 1
                            : 0),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index == _controller.filteredMembers.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      }
                      final member = _controller.filteredMembers[index];
                      return AddedMemberCard(member: member);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed<void>(AppRouter.addFamilyMember)?.then((_) {
              _controller.refreshMembers();
            });
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          icon: Icon(
            Icons.person_add_alt_1_rounded,
            color: AppColors.white,
            size: 20.sp,
          ),
          label: Text(
            LK.addMember.tr,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsPanel() {
    return Obx(() {
      if (_controller.members.isEmpty) {
        return const SizedBox.shrink();
      }

      final tabs = ['all', 'approved', 'requested', 'rejected'];
      final selectedIndex = tabs.indexOf(_controller.selectedTab.value);

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final double tabWidth = totalWidth / 4;

            return Container(
              height: 52.h,
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
                    width: tabWidth - 10.w,
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
                        tabKey: 'all',
                        label: LK.membersCount.tr,
                        count: '${_controller.totalCount.value}',
                        isSelected: selectedIndex == 0,
                        defaultColor: AppColors.primary,
                      ),
                      _buildCustomTabItem(
                        tabKey: 'approved',
                        label: 'Approved'.tr,
                        count: '${_controller.approvedCount.value}',
                        isSelected: selectedIndex == 1,
                        defaultColor: AppColors.green,
                      ),
                      _buildCustomTabItem(
                        tabKey: 'requested',
                        label: 'Requested'.tr,
                        count: '${_controller.requestedCount.value}',
                        isSelected: selectedIndex == 2,
                        defaultColor: AppColors.chart5,
                      ),
                      _buildCustomTabItem(
                        tabKey: 'rejected',
                        label: 'Rejected'.tr,
                        count: '${_controller.rejectedCount.value}',
                        isSelected: selectedIndex == 3,
                        defaultColor: AppColors.red,
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
    required String tabKey,
    required String label,
    required String count,
    required bool isSelected,
    required Color defaultColor,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _controller.setSelectedTab(tabKey);
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : defaultColor,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
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
}
