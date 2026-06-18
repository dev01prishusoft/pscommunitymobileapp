import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/mappers/gender_mapper.dart';

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

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('occupationId')) {
      _occupationId = args['occupationId'] as int;
      _occupationName = (args['occupationName'] as String?) ?? LK.occupationProfile.tr;
      controller.loadOccupationMembers(_occupationId);
    }
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        controller.loadOccupationMembers(_occupationId, refresh: false);
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(title: Text(_occupationName)),
      body: Obx(
        () => AppStateView(
          state: controller.membersState.value,
          onRetry: () => controller.loadOccupationMembers(_occupationId),
          child: RefreshIndicator(
            onRefresh: () => controller.loadOccupationMembers(_occupationId, refresh: true),
            color: AppColors.primary,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.occupationMembers.length + (controller.hasMoreMembers.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.occupationMembers.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return _OccupationMemberCard(member: controller.occupationMembers[index]);
              },
            ),
          ),
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
          fallbackName: member.name,
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
