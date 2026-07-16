import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';

class FindMemberPage extends StatefulWidget {
  const FindMemberPage({super.key});

  @override
  State<FindMemberPage> createState() => _FindMemberPageState();
}

class _FindMemberPageState extends State<FindMemberPage> {
  final FindMemberController _controller = Get.find<FindMemberController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.findMember.tr)),
      body: Column(
        children: [
          15.verticalSpace,
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppTextField(
              hint: LK.searchHint.tr,
              icon: Iconsax.search_normal_copy,
              controller: _searchController,
              onChanged: _controller.updateSearch,
              suffixIcon: Obx(() {
                return _controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.cancel_rounded,
                          color: AppColors.grey,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _controller.clearSearch();
                        },
                      )
                    : const SizedBox.shrink();
              }),
            ),
          ),
          10.verticalSpace,
          Obx(
            () => Row(
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  size: 16.sp,
                  color: AppColors.grey,
                ),
                SizedBox(width: 6.w),
                Text(
                  LK.showing.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ' ${_controller.items.length} ',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  LK.membersCount.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ).paddingOnly(left: 5.w),
          ),
          15.verticalSpace,
          Expanded(
            child: PaginatedListView<Member, FindMemberController>(
              emptyMessage: LK.noMembersFound.tr,
              padding: EdgeInsetsGeometry.zero,
              itemBuilder: (context, index, member) =>
                  _FindMemberCard(member: member),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 14.w),
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

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed<void>(
              AppRouter.memberProfile,
              arguments: {'memberId': member.memberId},
            );
          },
          child: Padding(
            padding: EdgeInsets.all(10.w),
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
                                color: AppColors.grey,
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
                                color: AppColors.primary,
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
          ),
        ),
      ),
    );
  }
}
