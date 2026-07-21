import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/marital_status_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/relation_mapper.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.member, required this.showDivider});

  final FamilyMember member;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider)
          Divider(
            indent: 72.w,
            endIndent: 16.w,
            height: 1.h,
            color: AppColors.grey.withValues(alpha: 0.12),
          ),
        InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed<void>(
              AppRouter.memberProfile,
              arguments: {'memberId': int.tryParse(member.id) ?? 0},
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                _buildAvatar(),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (member.isHead) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: AppColors.green.withValues(alpha: 0.15),
                                  width: 1.w,
                                ),
                              ),
                              child: Text(
                                LK.familyHead.tr,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Builder(
                        builder: (context) {
                          final genderKey = GenderMapper.getLabelKey(
                            member.gender,
                          );
                          final relKey = RelationMapper.getLabelKey(
                            member.relation,
                          );
                          final statusKey = MaritalStatusMapper.getLabelKey(
                            member.maritalStatus,
                          );

                          final metaStyle = AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          );
                          final dot = Text(
                            ' • ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey,
                            ),
                          );

                          return Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                genderKey != null
                                    ? genderKey.tr
                                    : member.gender,
                                style: metaStyle,
                              ),
                              dot,
                              Text(
                                relKey != null ? relKey.tr : member.relation,
                                style: metaStyle,
                              ),
                              dot,
                              Text(
                                statusKey != null
                                    ? statusKey.tr
                                    : member.maritalStatus,
                                style: metaStyle,
                              ),
                              if (member.occupation.isNotEmpty &&
                                  member.occupation.toLowerCase() != 'n/a' &&
                                  member.occupation.toLowerCase() !=
                                      'none') ...[
                                dot,
                                Text(member.occupation, style: metaStyle),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey.shade400,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return MemberAvatar(
      imageUrl: member.profileImageUrl,
      gender: member.gender,
      fallbackName: member.name,
      radius: 22.r,
    );
  }
}
