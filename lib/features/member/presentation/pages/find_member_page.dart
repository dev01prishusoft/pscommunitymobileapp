import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/presentation/controllers/find_member_controller.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';

import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';

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
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(LK.findMember.tr, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _controller.updateSearch,
              decoration: InputDecoration(
                hintText: LK.searchHint.tr,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.mutedForeground,
                ),
                suffixIcon: Obx(() {
                  if (_controller.isRefreshing.value && _controller.items.isNotEmpty) {
                    return SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }
                  return _controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.mutedForeground,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _controller.clearSearch();
                          },
                        )
                      : SizedBox.shrink();
                }),
                filled: true,
                fillColor: AppColors.slate,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Text(
                    LK.showing.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    ' ${_controller.items.length} ',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    LK.membersCount.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PaginatedListView<Member, FindMemberController>(
              emptyMessage: LK.noMembersFound.tr,
              itemBuilder: (context, index, member) => _buildMemberCard(member),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return _FindMemberCard(member: member);
  }
}

class _FindMemberCard extends StatelessWidget {
  const _FindMemberCard({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    final infoParts = <String>[];
    final genderKey = GenderMapper.getLabelKey(member.gender);
    if (genderKey != null) {
      infoParts.add(genderKey.tr);
    } else if (member.gender.isNotEmpty) {
      infoParts.add(member.gender);
    }

    if (member.age > 0) infoParts.add('${member.age} ${LK.ageYears.tr}');
    if (member.occupation.isNotEmpty) infoParts.add(member.occupation);
    final infoString = infoParts.join(' • ');

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: MemberAvatar(
          imageUrl: member.profilePhotoFullUrl,
          gender: member.gender,
          radius: 30,
        ),
        title: Text(
          member.name,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.secondary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (infoString.isNotEmpty) ...[
              AppSpacing.vS,
              Text(
                infoString,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
            if (member.area.isNotEmpty) ...[
              AppSpacing.vM,
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.primary),
                  AppSpacing.hS,
                  Expanded(
                    child: Text(
                      member.area,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: AppColors.primary),
        onTap: () => Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': member.memberId},
        ),
      ),
    );
  }
}
