import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/presentation/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  final FamilyController _controller = Get.find<FamilyController>();
  int _memberId = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('memberId')) {
      _memberId = args['memberId'] as int;
      _controller.loadMemberDetails(_memberId);
    } else {
      _controller.selectedMember.value = null;
      _controller.memberDetailState.value = AppState.loading;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          LK.memberDetails.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => AppStateView(
            state: _controller.memberDetailState.value,
            onRetry: () => _controller.loadMemberDetails(_memberId),
            child: _ProfileContent(),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => _controller.memberDetailState.value == AppState.data
            ? SafeArea(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Get.back<void>(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 54),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      LK.close.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}

class _ProfileContent extends GetView<FamilyController> {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final member = controller.selectedMember.value;
    if (member == null) return SizedBox.shrink();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          _ProfileHeader(member: member),
          _MemberDetailsSection(member: member, controller: controller),
          if (controller.memberAddresses.isNotEmpty)
            _AddressSection(controller: controller),
          _AssetLifeSection(member: member, controller: controller),
          _SocialMediaSection(member: member, controller: controller),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {

  const _ProfileHeader({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2.w),
            ),
            child: MemberAvatar(
              imageUrl: member.profilePhotoFullUrl,
              gender: member.gender,
              fallbackName: member.fullName,
              radius: 40.r,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  member.memberNo ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        member.jobPositionName ?? 'Member',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberDetailsSection extends StatelessWidget {

  const _MemberDetailsSection({required this.member, required this.controller});
  final Member member;
  final FamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      child: Column(
        children: [
          _buildDetailRow(
            _buildGridItem(
              Icons.person_outline,
              LK.gender.tr,
              controller.formatGender(member),
            ),
            _buildGridItem(
              Icons.water_drop_outlined,
              LK.bloodGroupColon.tr,
              controller.formatBloodGroup(member),
            ),
          ),
          _buildDetailRow(
            _buildGridItem(
              Icons.calendar_today_outlined,
              LK.birthDate.tr,
              controller.getFormattedDateOfBirth(member),
            ),
            _buildGridItem(
              Icons.height,
              LK.heightColon.tr,
              '${member.height ?? 0} cm',
            ),
          ),
          _buildDetailRow(
            _buildGridItem(
              Icons.access_time,
              LK.birthTime.tr,
              member.dateOfBirthTime ?? LK.na,
            ),
            _buildGridItem(
              Icons.monitor_weight_outlined,
              LK.weightColon.tr,
              '${member.weight ?? 0} kg',
            ),
          ),
          _buildDetailRow(
            _buildGridItem(
              Icons.person_outline,
              LK.motherFatherName.tr,
              controller.formatMotherFather(member),
            ),
            _buildGridItem(
              Icons.work_outline,
              LK.occupationLabel.tr,
              controller.formatOccupation(member),
            ),
          ),
          _buildDetailRow(
            _buildGridItem(
              Icons.location_on_outlined,
              LK.occupationArea.tr,
              controller.formatOccupationArea(member),
            ),
            _buildGridItem(
              Icons.favorite_border,
              LK.maritalStatusLabel.tr,
              controller.formatMaritalStatus(member),
            ),
          ),
          _buildDetailRow(
            _buildGridItem(
              Icons.phone_outlined,
              LK.mobileNoLabel.tr,
              controller.formatMobileNo(member),
              onTap: member.mobileNo != null
                  ? () => controller.launchSafeUrl('tel:${member.mobileNo}')
                  : null,
            ),
            _buildGridItem(
              Icons.contact_phone_outlined,
              LK.emergencyContact.tr,
              controller.formatEmergencyContact(member),
              onTap: member.emergencyContactNo != null
                  ? () => controller.launchSafeUrl(
                      'tel:${member.emergencyContactNo}',
                    )
                  : null,
            ),
          ),
          _buildDetailRow(
            _buildGridItem(
              Icons.opacity,
              LK.gotraLabel.tr,
              controller.formatGotra(member),
            ),
            _buildGridItem(
              Icons.mail_outline,
              LK.email.tr,
              controller.formatEmail(member),
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(Widget item1, Widget item2, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: item1),
          SizedBox(width: 12.w),
          Expanded(child: item2),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.mutedForeground,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {

  const _AddressSection({required this.controller});
  final FamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: LK.memberAddresses.tr,
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.memberAddresses.map((addr) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        addr.addressTypeName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (addr.isPrimary) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  addr.fullAddress,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.secondary,
                    height: 1.5.h,
                  ),
                ),
                if (controller.memberAddresses.last != addr)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Divider(height: 1.h),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AssetLifeSection extends StatelessWidget {
  const _AssetLifeSection({required this.member, required this.controller});
  final Member member;
  final FamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: LK.assetAndLife.tr,
      icon: Icons.work_outline,
      child: Column(
        children: [
          _buildAssetRow(
            LK.incomeColon.tr,
            '₹${member.monthlyIncome ?? 0}',
            LK.ownHouse.tr,
            member.isOwnHouse ?? false,
          ),
          _buildAssetRow(
            LK.ownLand.tr,
            member.isOwnLand ?? false,
            LK.twoWheeler.tr,
            member.hasTwoWheeler ?? false,
          ),
          _buildAssetRow(
            '',
            '',
            LK.fourWheeler.tr,
            member.hasFourWheeler ?? false,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(
    String label1,
    dynamic value1,
    String label2,
    bool value2,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: label1.isNotEmpty
                ? Row(
                    children: [
                      Text(
                        label1,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      Spacer(),
                      if (value1 is bool)
                        Icon(
                          value1 ? Icons.check_circle : Icons.cancel,
                          size: 18,
                          color: value1
                              ? AppColors.success
                              : AppColors.destructive,
                        )
                      else
                        Text(
                          value1.toString(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                    ],
                  )
                : SizedBox.shrink(),
          ),
          SizedBox(width: 32.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  label2,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.mutedForeground,
                  ),
                ),
                Spacer(),
                Icon(
                  value2 ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: value2 ? AppColors.success : AppColors.destructive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialMediaSection extends StatelessWidget {
  const _SocialMediaSection({required this.member, required this.controller});
  final Member member;
  final FamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: LK.socialMedia.tr,
      icon: Icons.share_outlined,
      child: Column(
        children: [
          _buildSocialRow(
            _buildSocialItem(
              Icons.facebook,
              LK.facebook.tr,
              member.facebookUrl ?? LK.na,
              AppColors.blue,
              onTap: member.facebookUrl != null
                  ? () => controller.launchSafeUrl(member.facebookUrl!)
                  : null,
            ),
            _buildSocialItem(
              Icons.camera_alt_outlined,
              LK.instagram.tr,
              member.instagramUrl ?? LK.na,
              Colors.pink,
              onTap: member.instagramUrl != null
                  ? () => controller.launchSafeUrl(member.instagramUrl!)
                  : null,
            ),
          ),
          _buildSocialRow(
            _buildSocialItem(
              Icons.chat_bubble_outline,
              LK.whatsapp.tr,
              member.whatsappUrl ?? LK.na,
              AppColors.green,
              onTap: member.whatsappUrl != null
                  ? () => controller.launchSafeUrl(member.whatsappUrl!)
                  : null,
            ),
            _buildSocialItem(
              Icons.alternate_email,
              LK.twitterX.tr,
              member.twitterUrl ?? LK.na,
              AppColors.black,
              onTap: member.twitterUrl != null
                  ? () => controller.launchSafeUrl(member.twitterUrl!)
                  : null,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(Widget item1, Widget item2, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: item1),
          SizedBox(width: 12.w),
          Expanded(child: item2),
        ],
      ),
    );
  }

  Widget _buildSocialItem(
    IconData icon,
    String label,
    String handle,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(icon, size: 22, color: color),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.mutedForeground,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  handle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {

  const _SectionContainer({this.title, this.icon, required this.child});
  final String? title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
          child,
        ],
      ),
    );
  }
}
