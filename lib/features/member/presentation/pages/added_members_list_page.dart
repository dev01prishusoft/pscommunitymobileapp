import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _controller.fetchMembers();
      }
    });
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    Get.delete<AddedMembersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.addedMembers.tr)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          15.verticalSpace,
          _buildSearchBar(),
          10.verticalSpace,
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
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AppTextField(
        hint: LK.searchHint.tr,
        icon: Icons.search_rounded,
        suffixIcon: Obx(() {
          final isQueryNotEmpty = _controller.searchQuery.value.isNotEmpty;
          return isQueryNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.grey.shade500,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _controller.onSearchChanged('');
                  },
                )
              : const SizedBox.shrink();
        }),
        controller: _searchController,
        onChanged: _controller.onSearchChanged,
      ),
    );
  }

  Widget _buildStatsPanel() {
    return Obx(() {
      if (_controller.members.isEmpty && !_controller.isLoading.value) {
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

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
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
                title: LK.membersCount.tr,
                value: '$total',
                icon: Icons.people_alt_rounded,
                color: AppColors.primary,
                bgColor: AppColors.primary.withValues(alpha: 0.08),
              ),
              Container(
                height: 30.h,
                width: 1,
                margin: EdgeInsets.all(5.w),
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
                margin: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              _buildStatItem(
                title: 'Pending'.tr,
                value: '$pending',
                icon: Icons.pending_rounded,
                color: const Color(0xFFEF6C00),
                bgColor: const Color(0xFFFFF3E0),
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
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
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
      ).paddingOnly(left: 5),
    );
  }
}
