import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';

class CommitteeDetailsPage extends StatefulWidget {
  const CommitteeDetailsPage({super.key});

  @override
  State<CommitteeDetailsPage> createState() => _CommitteeDetailsPageState();
}

class _CommitteeDetailsPageState extends State<CommitteeDetailsPage> {
  final controller = Get.find<CommitteeController>();
  late CommitteeNode node;

  @override
  void initState() {
    super.initState();
    node = Get.arguments as CommitteeNode;
    controller.loadCommitteeDetail(node.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(title: Text(node.name)),
      body: Obx(
        () => AppStateView(
          state: controller.detailState.value,
          onRetry: () => controller.loadCommitteeDetail(node.id),
          child: _buildContent(controller.committeeDetail.value),
        ),
      ),
    );
  }

  Widget _buildContent(CommitteeDetail? detail) {
    if (detail == null) return SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSection(
            title: LK.committeeInfo.tr,
            icon: Icons.account_balance,
            child: Column(
              children: [
                _buildInfoRow(LK.nameLabel.tr, detail.name),
                Divider(height: 12.h, thickness: 0.5),
                _buildInfoRow(LK.descriptionLabel.tr, detail.description),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (detail.roles.isNotEmpty)
            _buildSection(
              title:
                  '${LK.roles.tr} ${LK.at.tr.toUpperCase()} (${detail.roles.length})',
              icon: Icons.verified_user,
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: detail.roles.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final role = detail.roles[index];
                  return _buildRoleTile(
                    _getRoleIcon(role.roleTypeName),
                    role.roleName,
                    role.roleTypeName,
                    role.memberCount,
                  );
                },
              ),
            ),
          SizedBox(height: 16.h),
          _buildSection(
            title: '${LK.membersCount.tr} (${detail.members.length})',
            icon: Icons.groups,
            child: Column(
              children: [
                if (detail.members.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(LK.noMembersFound.tr),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: detail.members.length > 3
                        ? 3
                        : detail.members.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final member = detail.members[index];
                      return _buildMemberTile(
                        context,
                        member.memberId,
                        member.name,
                        formatDateString(member.startDate, fallback: '-'),
                        formatDateString(member.endDate, fallback: '-'),
                        member.roleName,
                        '',
                      );
                    },
                  ),
                if (detail.members.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.committeeMembers,
                        arguments: node,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LK.showMore.tr,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'head':
      case 'leadership':
        return Icons.person;
      case 'administrative':
        return Icons.assignment;
      case 'financial':
        return Icons.currency_rupee;
      default:
        return Icons.verified_user;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTile(
    IconData icon,
    String title,
    String subtitle,
    int count,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    int memberId,
    String name,
    String since,
    String endDate,
    String tag,
    String imageUrl,
  ) {
    return InkWell(
      onTap: () {
        Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': memberId},
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            MemberAvatar(
              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
              fallbackName: name,
              radius: 28.r,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      children: [
                        TextSpan(text: 'Start: '),
                        TextSpan(text: since, style: AppTextStyles.labelSmall),
                        TextSpan(text: ' | End: '),
                        TextSpan(text: endDate, style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
