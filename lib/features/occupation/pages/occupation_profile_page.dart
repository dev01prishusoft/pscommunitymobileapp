import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/app_card.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';

import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/features/occupation/controllers/occupation_controller.dart';

class OccupationProfilePage extends StatefulWidget {
  const OccupationProfilePage({super.key});

  @override
  State<OccupationProfilePage> createState() => _OccupationProfilePageState();
}

class _OccupationProfilePageState extends State<OccupationProfilePage> {
  final controller = Get.find<OccupationController>();
  int _occupationId = 0;
  String _occupationName = '';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('occupationId')) {
      _occupationId = args['occupationId'] as int;
      _occupationName =
          (args['occupationName'] as String?) ?? LK.occupationProfile.tr;

      controller.activeOccupationId.value = _occupationId;
      controller.memberSearchQuery.value = '';
      controller.loadOccupationMembers(_occupationId, refresh: true);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadOccupationMembers(_occupationId, refresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    controller.clearMemberSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    controller.clearMemberSearch();
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
                placeholder: LK.searchMember.tr,
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _searchController.clear();
                    controller.clearMemberSearch();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _isSearchVisible = false;
                    });
                  } else {
                    controller.searchMembers(value);
                  }
                },
              )
            : Text(_occupationName.tr),
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
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => AppStateView(
                  state: controller.membersState.value,
                  onRetry: () =>
                      controller.loadOccupationMembers(_occupationId),
                  child: RefreshIndicator(
                    onRefresh: () => controller.loadOccupationMembers(
                      _occupationId,
                      refresh: true,
                    ),
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          controller.occupationMembers.length +
                          (controller.hasMoreMembers.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.occupationMembers.length) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        return _OccupationMemberCard(
                          member: controller.occupationMembers[index],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccupationMemberCard extends StatelessWidget {
  const _OccupationMemberCard({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 5.h),
      elevation: 0.02,
      border: Border.all(
        color: AppColors.grey.withValues(alpha: 0.12),
        width: 1.w,
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.toNamed<void>(
          AppRouter.frompageOccupation,
          arguments: {'memberId': member.memberId},
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MemberAvatar(
            imageUrl: member.profilePhotoFullUrl,
            gender: member.gender,
            fallbackName: member.name,
            radius: 28.r,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    if (member.occupation.isNotEmpty)
                      _buildBadge(
                        member.occupation,
                        Icons.work_rounded,
                        AppColors.primary.withValues(alpha: 0.05),
                        AppColors.primary,
                      ),
                  ],
                ),
                if (member.occupationAreaName != null &&
                        member.occupationAreaName!.isNotEmpty ||
                    member.occupationTalukaName != null &&
                        member.occupationTalukaName!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14.r,
                        color: AppColors.grey.shade700,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          "${member.occupationAreaName}, ${member.occupationTalukaName}",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.sfBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    String label,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 0.5.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: textColor),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
