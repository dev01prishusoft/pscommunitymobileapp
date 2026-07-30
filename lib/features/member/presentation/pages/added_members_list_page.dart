import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/widgets/app_empty_state.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/added_members_controller.dart';
import 'package:pscommunitymobileapp/features/member/presentation/widgets/added_member_card.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

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
              ? CupertinoTextField(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                  prefix: Icon(
                    Iconsax.search_normal_copy,
                    size: 15,
                  ).paddingOnly(left: 10),
                  suffix: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _controller.onSearchChanged('');
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        _isSearchVisible = false;
                      });
                    },
                    child: Icon(
                      Iconsax.close_circle_copy,
                      size: 20,
                    ).paddingOnly(right: 10),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1.w,
                    ),
                  ),
                  placeholder: LK.searchHint.tr,
                  controller: _searchController,
                  onChanged: _controller.onSearchChanged,
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
          _buildStatsPanel(),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.members.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_controller.members.isEmpty && !_controller.isLoading.value) {
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
                      _controller.members.length +
                      (_controller.hasMore.value ? 1 : 0),
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    if (index == _controller.members.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    final member = _controller.members[index];
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

      final total = _controller.totalCount.value;
      final approved = _controller.members
          .where((m) => m.approveStatus?.toLowerCase() == 'approved')
          .length;
      final pending = _controller.members
          .where(
            (m) =>
                m.approveStatus?.toLowerCase() != 'approved' &&
                m.approveStatus?.toLowerCase() != 'rejected',
          )
          .length;
      final rejected = _controller.members
          .where((m) => m.approveStatus?.toLowerCase() == 'rejected')
          .length;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.grey.withValues(alpha: 0.15),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                title: total == 1 ? LK.member.tr : LK.membersCount.tr,
                value: '$total',
                icon: Icons.people_alt_rounded,
                color: AppColors.primary,
                bgColor: AppColors.primary.withValues(alpha: 0.08),
              ),
              Container(
                height: 30.h,
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              _buildStatItem(
                title: 'Approved'.tr,
                value: '$approved',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF2E7D32),
                bgColor: const Color(0xFFE8F5E9),
              ),
              Container(
                height: 30.h,
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              _buildStatItem(
                title: 'Requested'.tr,
                value: '$pending',
                icon: Icons.pending_rounded,
                color: const Color(0xFFEF6C00),
                bgColor: const Color(0xFFFFF3E0),
              ),
              Container(
                height: 30.h,
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              _buildStatItem(
                title: 'Rejected'.tr,
                value: '$rejected',
                icon: Icons.cancel_rounded,
                color: const Color(0xFFC62828),
                bgColor: const Color(0xFFFFEBEE),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
