import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/constants/mappers.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/app_card.dart';

import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/features/member/controllers/find_member_controller.dart';

class FindMemberPage extends StatefulWidget {
  const FindMemberPage({super.key});

  @override
  State<FindMemberPage> createState() => _FindMemberPageState();
}

class _FindMemberPageState extends State<FindMemberPage> {
  final FindMemberController _controller = Get.find<FindMemberController>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearchVisible
              ? CupertinoTextField(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 9.h,
                  ),
                  prefix: Icon(
                    Iconsax.search_normal_copy,
                    size: 15,
                  ).paddingOnly(left: 10),
                  suffix: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _controller.clearSearch();
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
                  onChanged: _controller.updateSearch,
                )
              : Text(LK.findMember.tr),
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
        body: PaginatedListView<Member, FindMemberController>(
          emptyMessage: LK.noMembersFound.tr,
          padding: AppSpacing.pagePadding,
          separatorBuilder: (val, val2) => SizedBox(height: 6.h),
          itemBuilder: (context, index, member) =>
              _FindMemberCard(member: member),
        ),
      ),
    );
  }
}

class _FindMemberCard extends StatelessWidget {
  const _FindMemberCard({required this.member});
  final Member member;

  Widget _buildHeadBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 0.5.w,
        ),
      ),
      child: Text(
        LK.familyHead.tr,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildMarriageBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.pink.withValues(alpha: 0.2),
          width: 0.5.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, size: 10.sp, color: AppColors.pink),
          SizedBox(width: 3.w),
          Text(
            LK.lookingForMarriage.tr,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.pink,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderAgeBadge() {
    final infoParts = <String>[];
    final genderKey = GenderMapper.getLabelKey(member.gender);
    if (genderKey != null) {
      infoParts.add(genderKey.tr);
    } else if (member.gender.isNotEmpty) {
      infoParts.add(member.gender);
    }
    if (member.age > 0) {
      infoParts.add('${member.age} ${LK.ageYears.tr}');
    }
    final text = infoParts.join(' • ');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 0.5.w,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.grey.shade800,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildGotraBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.blue.shade50,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.blue.shade100, width: 0.5.w),
      ),
      child: Text(
        '${LK.gotraLabel.tr} ${member.gotra}',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.blue.shade900,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String occupationText = member.occupation;
    if (member.companyName != null && member.companyName!.isNotEmpty) {
      occupationText += ' @ ${member.companyName}';
    } else if (member.businessName != null && member.businessName!.isNotEmpty) {
      occupationText += ' @ ${member.businessName}';
    }

    return AppCard(
      elevation: 0.02,
      border: Border.all(
        color: AppColors.grey.withValues(alpha: 0.15),
        width: 1.w,
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': member.memberId},
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: MemberAvatar(
                imageUrl: member.profilePhotoFullUrl,
                gender: member.gender,
                fallbackName: member.name,
                radius: 26.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 8.h,
                    children: [
                      if (member.isHead == true) _buildHeadBadge(),
                      if (member.isLookingforMarriage == true)
                        _buildMarriageBadge(),
                      _buildGenderAgeBadge(),
                      if (member.gotra.isNotEmpty) _buildGotraBadge(),
                    ],
                  ),
                  if (member.occupation.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.business_center_outlined,
                          size: 13.sp,
                          color: AppColors.grey.shade700,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            occupationText,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (member.area.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13.sp,
                          color: AppColors.grey.shade700,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            member.area,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Center(
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

