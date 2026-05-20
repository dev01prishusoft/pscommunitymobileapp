import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/marital_status_mapper.dart';
import 'package:pscommunitymobileapp/core/mappers/relation_mapper.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.member,
    required this.showDivider,
  });

  final FamilyMember member;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final avatarColors = _getAvatarColors(member.gender);
    
    return Column(
      children: [
        if (showDivider)
          const Divider(indent: 70, endIndent: 16),
        InkWell(
          onTap: () => Get.toNamed<void>(
            AppRouter.memberProfile,
            arguments: {'memberId': int.tryParse(member.id) ?? 0},
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildAvatar(avatarColors),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.secondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (member.isHead) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7), // specific accent color
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                LK.familyHead.tr,
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final genderKey = GenderMapper.getLabelKey(member.gender);
                          final relKey = RelationMapper.getLabelKey(member.relation);
                          final statusKey = MaritalStatusMapper.getLabelKey(member.maritalStatus);
                          
                          const metaStyle = TextStyle(fontSize: 12, color: AppColors.mutedForeground);
                          const dot = Text(' • ', style: metaStyle);
                          
                          return Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(genderKey != null ? genderKey.tr : member.gender, style: metaStyle),
                              dot,
                              Text(relKey != null ? relKey.tr : member.relation, style: metaStyle),
                              dot,
                              Text(statusKey != null ? statusKey.tr : member.maritalStatus, style: metaStyle),
                              if (member.occupation.isNotEmpty && member.occupation.toLowerCase() != 'n/a' && member.occupation.toLowerCase() != 'none') ...[
                                dot,
                                Text(member.occupation, style: metaStyle),
                              ],
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.border, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(({Color background, Color text}) colors) {
    final initial = member.name.isNotEmpty ? member.name[0].toUpperCase() : '';
    
    Widget fallbackAvatar() => CircleAvatar(
      radius: 22,
      backgroundColor: colors.background,
      child: Text(
        initial,
        style: TextStyle(
          color: colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );

    if (member.profileImageUrl == null || member.profileImageUrl!.isEmpty) {
      return fallbackAvatar();
    }

    return CachedNetworkImage(
      imageUrl: member.profileImageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 22,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: 22,
        backgroundColor: colors.background,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) => fallbackAvatar(),
    );
  }

  ({Color background, Color text}) _getAvatarColors(String gender) {
    if (gender == 'Female') {
      return (background: const Color(0xFFFDE7F3), text: const Color(0xFFD61A87));
    }
    return (background: const Color(0xFFE2F1FB), text: const Color(0xFF1AA3E8));
  }
}
