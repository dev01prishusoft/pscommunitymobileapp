import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/presentation/controllers/committee_controller.dart';

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
    if (detail == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: AppColors.white,
                        size: 24.r,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        LK.committeeInfo.tr.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  detail.name,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (detail.description.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    detail.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (detail.roles.isNotEmpty)
            _buildSection(
              title: '${LK.roles.tr} (${detail.roles.length})',
              icon: Icons.verified_user_rounded,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: detail.roles.length,
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
            title: '${detail.members.length == 1 ? LK.member.tr : LK.membersCount.tr} (${detail.members.length})',
            icon: Icons.groups_rounded,
            child: Column(
              children: [
                if (detail.members.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      LK.noMembersFound.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: detail.members.length > 3
                        ? 3
                        : detail.members.length,
                    itemBuilder: (context, index) {
                      final member = detail.members[index];
                      return _buildMemberTile(
                        context,
                        member.memberId,
                        member.name,
                        formatDateString(member.startDate, fallback: '-'),
                        formatDateString(member.endDate, fallback: '-'),
                        member.roleName,
                        member.imageUrl ?? '',
                      );
                    },
                  ),
                if (detail.members.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.committeeMembers,
                        arguments: node,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      minimumSize: Size(double.infinity, 44.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LK.showMore.tr,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16.r,
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
        return Icons.person_rounded;
      case 'administrative':
        return Icons.assignment_rounded;
      case 'financial':
        return Icons.currency_rupee_rounded;
      default:
        return Icons.verified_user_rounded;
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20.r),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
            child: child,
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
    Color typeColor;
    Color bgTint;

    final subLower = subtitle.toLowerCase();
    if (subLower.contains('head') || subLower.contains('leadership')) {
      typeColor = AppColors.chart5;
      bgTint = AppColors.chart5.withValues(alpha: 0.1);
    } else if (subLower.contains('financial') || subLower.contains('finance')) {
      typeColor = AppColors.green;
      bgTint = AppColors.green.withValues(alpha: 0.1);
    } else if (subLower.contains('admin')) {
      typeColor = AppColors.blue;
      bgTint = AppColors.blue.withValues(alpha: 0.1);
    } else {
      typeColor = AppColors.primary;
      bgTint = AppColors.primary.withValues(alpha: 0.1);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: bgTint, shape: BoxShape.circle),
              child: Icon(icon, color: typeColor, size: 22.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count ${count == 1 ? LK.member.tr.toLowerCase() : LK.membersCount.tr.toLowerCase()}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed<void>(
            AppRouter.memberProfile,
            arguments: {'memberId': memberId},
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: MemberAvatar(
                  imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                  fallbackName: name,
                  radius: 20.r,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      tag,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary.withValues(alpha: 0.4),
                size: 14.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
