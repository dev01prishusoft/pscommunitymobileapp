import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/app_text_field.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';

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
      appBar: AppBar(title: Text(_occupationName.tr)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          15.verticalSpace,
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppTextField(
              controller: _searchController,
              hint: LK.searchMember.tr,
              icon: Iconsax.search_normal_copy,
              onChanged: controller.searchMembers,
              suffixIcon: Obx(
                () => controller.memberSearchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20.r,
                          color: AppColors.grey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          controller.clearMemberSearch();
                        },
                      )
                    : const SizedBox.shrink(),
              ),
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
                  ' ${controller.occupationMembers.length} ',
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
            child: Obx(
              () => AppStateView(
                state: controller.membersState.value,
                onRetry: () => controller.loadOccupationMembers(_occupationId),
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
      ).paddingSymmetric(horizontal: 16.w),
    );
  }
}

class _OccupationMemberCard extends StatelessWidget {
  const _OccupationMemberCard({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    final genderLabel =
        GenderMapper.getLabelKey(member.gender)?.tr ?? member.gender;
    final isFemale =
        member.gender.toLowerCase().contains('fem') ||
        member.gender.toLowerCase().contains('stri');

    return Container(
      margin: EdgeInsets.only(bottom: 5.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.12),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': member.memberId},
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
                        if (genderLabel.isNotEmpty)
                          _buildBadge(
                            genderLabel,
                            isFemale
                                ? Icons.female_rounded
                                : Icons.male_rounded,
                            isFemale
                                ? const Color(0xFFFFEEF0)
                                : const Color(0xFFE8F0FE),
                            isFemale
                                ? const Color(0xFFD81B60)
                                : const Color(0xFF1A73E8),
                          ),
                        if (member.age > 0)
                          _buildBadge(
                            '${member.age} ${LK.ageYears.tr}',
                            Icons.cake_rounded,
                            const Color(0xFFFEF7E0),
                            const Color(0xFFB06000),
                          ),
                        if (member.occupation.isNotEmpty)
                          _buildBadge(
                            member.occupation,
                            Icons.work_rounded,
                            AppColors.primary.withValues(alpha: 0.05),
                            AppColors.primary,
                          ),
                      ],
                    ),
                    if (member.area.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14.r,
                            color: AppColors.grey,
                          ),
                          SizedBox(width: 4.w),
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
        ),
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
