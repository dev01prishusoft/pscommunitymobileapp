import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/family/models/family_tree_model.dart';

class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.width,
    required this.height,
    required this.onTap,
    this.isSelected = false,
  });

  final FamilyTreeNode member;
  final double width;
  final double height;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final gender = member.genderCategory;
    final bool isMale = gender == GenderCategory.male;
    final bool isFemale = gender == GenderCategory.female;

    final Color bgGradientStart = isMale
        ? AppColors.treeMaleBg
        : isFemale
            ? AppColors.treeFemaleBg
            : AppColors.treeOtherBg;

    final Color bgGradientEnd = isMale
        ? AppColors.treeMaleBgEnd
        : isFemale
            ? AppColors.treeFemaleBgEnd
            : AppColors.treeOtherBgEnd;

    final Color borderColor = isSelected
        ? AppColors.treeSelected
        : isMale
            ? AppColors.treeMaleBorder
            : isFemale
                ? AppColors.treeFemaleBorder
                : AppColors.treeOtherBorder;

    final Color primaryAccent = isMale
        ? AppColors.treeMaleAccent
        : isFemale
            ? AppColors.treeFemaleAccent
            : AppColors.treeOtherAccent;

    final String relationLabel = member.isHead
        ? LK.familyHead.tr
        : (member.relationTypeName ??
            (member.isLifePartner
                ? LK.Spouse.tr
                : (isMale
                    ? LK.male.tr
                    : (isFemale ? LK.female.tr : LK.other.tr))));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgGradientStart, bgGradientEnd],
        ),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.treeSelected.withValues(alpha: 0.35)
                : isMale
                    ? AppColors.treeMaleAccent.withValues(alpha: 0.08)
                    : isFemale
                        ? AppColors.treeFemaleAccent.withValues(alpha: 0.08)
                        : AppColors.treeOtherAccent.withValues(alpha: 0.08),
            blurRadius: isSelected ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Row: Role Badge & Gender/Demised Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Relation / Head badge
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: member.isHead
                                ? AppColors.treeHeadBg
                                : primaryAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: member.isHead
                                  ? AppColors.treeHead
                                  : primaryAccent.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (member.isHead) ...[
                                const Icon(
                                  Icons.star_rounded,
                                  size: 11,
                                  color: AppColors.treeHeadDark,
                                ),
                                const SizedBox(width: 2),
                              ],
                              Flexible(
                                child: Text(
                                  relationLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: member.isHead
                                        ? AppColors.treeHeadText
                                        : primaryAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Gender / Demised Marker
                      if (member.isDemised)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey.shade400,
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            size: 10,
                            color: AppColors.white,
                          ),
                        )
                      else
                        Icon(
                          isMale
                              ? Icons.male_rounded
                              : (isFemale
                                  ? Icons.female_rounded
                                  : Icons.person_rounded),
                          size: 14,
                          color: primaryAccent.withValues(alpha: 0.7),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Avatar / Photo
                  _MemberAvatar(
                    member: member,
                    gender: gender,
                    accentColor: primaryAccent,
                  ),

                  const SizedBox(height: 8),

                  // Full Name
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        member.fullName,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.treeSlateText,
                          height: 1.18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
    required this.gender,
    required this.accentColor,
  });

  final FamilyTreeNode member;
  final GenderCategory gender;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    const double size = 80.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: member.profileImageUrl != null &&
                member.profileImageUrl!.isNotEmpty
            ? CachedImg(
                url: member.profileImageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallbackAvatar(),
              )
            : _fallbackAvatar(),
      ),
    );
  }

  Widget _fallbackAvatar() {
    final gradient = gender == GenderCategory.male
        ? const LinearGradient(
            colors: [AppColors.treeMale, AppColors.treeMaleDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : gender == GenderCategory.female
            ? const LinearGradient(
                colors: [AppColors.treeFemale, AppColors.treeFemaleDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.treeOther, AppColors.treeOtherDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          member.initials,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
