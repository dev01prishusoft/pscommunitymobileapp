import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/widgets/full_screen_image_viewer.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/family/controllers/family_controller.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadMemberDetails(_memberId);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.selectedMember.value = null;
        _controller.memberDetailState.value = AppState.loading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.memberDetails.tr)),
      body: SafeArea(
        child: Obx(
          () => AppStateView(
            state: _controller.memberDetailState.value,
            onRetry: () => _controller.loadMemberDetails(_memberId),
            child: _ProfileContent(),
          ),
        ),
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
      padding: AppSpacing.pagePadding,
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          _ProfileHeader(member: member),
          _MemberDetailsSection(member: member, controller: controller),
          if (controller.memberAddresses.isNotEmpty)
            _AddressSection(controller: controller),
          Obx(() {
            if (controller.memberEducations.isNotEmpty) {
              return _EducationSection(controller: controller);
            }
            return SizedBox.shrink();
          }),
          _OccupationSection(member: member),
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
    final args = Get.arguments as Map<String, dynamic>?;
    final fromMyMemberList =
        args != null && (args['fromMyMemberList'] as bool? ?? false);
    final fromMatrimonial =
        args != null && (args['fromMatrimonial'] as bool? ?? false);

    final controller = Get.find<FamilyController>();
    final maritalStatus = controller.formatMaritalStatus(member);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (member.profilePhotoFullUrl != null &&
                      member.profilePhotoFullUrl!.isNotEmpty) {
                    Get.to(
                      () => FullScreenImageViewer(
                        imageUrl: member.profilePhotoFullUrl!,
                        heroTag: 'profile_image_${member.memberId}',
                      ),
                    );
                  }
                },
                child: Hero(
                  tag: 'profile_image_${member.memberId}',
                  child: MemberAvatar(
                    imageUrl: member.profilePhotoFullUrl,
                    gender: member.gender,
                    fallbackName: member.fullName,
                    radius: 30.r,
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  spacing: 5.h,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Row(
                      spacing: 8.w,
                      children: [
                        if (member.memberNo != null &&
                            member.memberNo!.trim().isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              member.memberNo ?? '',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        if (fromMatrimonial &&
                            maritalStatus.isNotEmpty &&
                            maritalStatus.toLowerCase() != 'n/a' &&
                            maritalStatus.toLowerCase() != 'null')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.pink.withValues(alpha: 0.12),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              maritalStatus,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (fromMyMemberList &&
              member.approveStatus != null &&
              member.approveStatus!.trim().isNotEmpty)
            _buildStatusBadge(member.approveStatus ?? ""),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    final lowerStatus = status.toLowerCase();
    final isRejected = lowerStatus == 'rejected';

    if (lowerStatus == 'approved') {
      color = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFE8F5E9);
    } else if (isRejected) {
      color = const Color(0xFFC62828);
      bgColor = const Color(0xFFFFEBEE);
    } else {
      color = const Color(0xFFEF6C00);
      bgColor = const Color(0xFFFFF3E0);
    }

    final badgeContent = Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.tr,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
          if (isRejected) ...[
            SizedBox(width: 4.w),
            Icon(Iconsax.info_circle_copy, size: 12.sp, color: color),
          ],
        ],
      ),
    );

    if (isRejected) {
      return GestureDetector(
        onTap: () => Get.dialog(
          Dialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.info_circle_copy,
                        color: AppColors.black,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Rejection Details'.tr,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20.h,
                    color: AppColors.grey.withValues(alpha: 0.07),
                  ),
                  Row(
                    spacing: 10.w,
                    children: [
                      Text(
                        '${'Status'.tr}:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        '${status.tr}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),

                  if (member.rejectedReasonCommentByAdmin != null &&
                      member.rejectedReasonCommentByAdmin!
                          .trim()
                          .isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      'Reason'.tr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      member.rejectedReasonCommentByAdmin!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Close'.tr,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: badgeContent,
      );
    }

    return badgeContent;
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
          // Mobile no and email
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
              Icons.mail_outline,
              LK.email.tr,
              controller.formatEmail(member),
              isExpandable: true,
            ),
          ),
          //birth date and birth time
          _buildDetailRow(
            _buildGridItem(
              Icons.calendar_today_outlined,
              LK.birthDate.tr,
              controller.getFormattedDateOfBirth(member),
            ),
            _buildGridItem(
              Icons.access_time,
              LK.birthTime.tr,
              controller.getFormattedBirthTime(member),
            ),
          ),
          // gender and marital status
          _buildDetailRow(
            _buildGridItem(
              Icons.person_outline,
              LK.gender.tr,
              controller.formatGender(member),
            ),
            _buildGridItem(
              Icons.favorite_border,
              LK.maritalStatusLabel.tr,
              controller.formatMaritalStatus(member),
            ),
          ),
          // blood group and gotra
          _buildDetailRow(
            _buildGridItem(
              Icons.water_drop_outlined,
              LK.bloodGroupColon.tr,
              controller.formatBloodGroup(member),
            ),
            _buildGridItem(
              Iconsax.hierarchy_2_copy,
              LK.gotraLabel.tr,
              controller.formatGotra(member),
            ),
          ),
          // height and weight
          _buildDetailRow(
            _buildGridItem(
              Icons.height,
              LK.heightColon.tr,
              controller.formatHeight(member),
            ),
            _buildGridItem(
              Icons.monitor_weight_outlined,
              LK.weightColon.tr,
              controller.formatWeight(member),
            ),
          ),
          // mother father name and occupation
          _buildDetailRow(
            _buildGridItem(
              Icons.person_outline,
              LK.motherFatherName.tr,
              controller.formatMotherFather(member),
              isExpandable: true,
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
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(Widget item1, Widget item2, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
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
    bool isExpandable = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 2.h),
                isExpandable
                    ? ExpandableText(
                        text: value,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        onTap: onTap,
                        isUnderline: onTap != null,
                      )
                    : Text(
                        value,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          decoration: onTap != null
                              ? TextDecoration.underline
                              : null,
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
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        addr.addressTypeName.tr,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (addr.isPrimary) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.2),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          LK.primary.tr,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (addr.addressLine1.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    maxLines: 2,
                    addr.addressLine1,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      height: 1.4,
                    ),
                  ),
                ],
                if (addr.addressLine2.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    maxLines: 2,
                    addr.addressLine2,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      height: 1.4,
                    ),
                  ),
                ],
                if (addr.landmark.isNotEmpty || addr.areaName.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    maxLines: 2,
                    "${addr.landmark} - ${addr.areaName}",
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      height: 1.4,
                    ),
                  ),
                ],
                if (addr.talukaName.isNotEmpty ||
                    addr.districtName.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    maxLines: 2,
                    "${addr.talukaName}, ${addr.districtName}",
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      height: 1.4,
                    ),
                  ),
                ],
                if (addr.stateName.isNotEmpty || addr.pincode.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    maxLines: 2,
                    "${addr.stateName}, ${addr.pincode}",
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      height: 1.4,
                    ),
                  ),
                ],
                if (controller.memberAddresses.last != addr)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Divider(
                      height: 1.h,
                      color: AppColors.grey.withValues(alpha: 0.05),
                    ),
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
        spacing: 10.h,
        children: [
          Row(
            spacing: 10.w,
            children: [
              Text(
                LK.incomeColon.tr,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
              ),
              Text(
                controller.formatIncome(member),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: _buildAssetRow(
                  LK.ownHouse.tr,
                  member.isOwnHouse ?? false,
                ),
              ),
              Expanded(
                child: _buildAssetRow(LK.ownLand.tr, member.isOwnLand ?? false),
              ),
            ],
          ),
          Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: _buildAssetRow(
                  LK.twoWheeler.tr,
                  member.hasTwoWheeler ?? false,
                ),
              ),
              Expanded(
                child: _buildAssetRow(
                  LK.fourWheeler.tr,
                  member.hasFourWheeler ?? false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(String label1, dynamic value1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label1,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
        ),
        if (value1 is bool)
          Text(
            value1 ? LK.yes.tr : LK.no.tr,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: value1 ? AppColors.green : AppColors.red,
            ),
          ),
      ],
    );
  }
}

class _SocialMediaSection extends StatelessWidget {
  const _SocialMediaSection({required this.member, required this.controller});
  final Member member;
  final FamilyController controller;

  bool _hasValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final lower = url.trim().toLowerCase();
    if (lower == 'na' || lower == 'n/a' || lower == 'null') return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidUrl(member.facebookUrl) &&
        !_hasValidUrl(member.instagramUrl) &&
        !_hasValidUrl(member.whatsappUrl) &&
        !_hasValidUrl(member.twitterUrl)) {
      return const SizedBox.shrink();
    }

    return _SectionContainer(
      title: LK.socialMedia.tr,
      icon: Icons.share_outlined,
      child: Column(
        children: [
          _buildSocialItem(
            Icons.facebook,
            LK.facebook.tr,
            member.facebookUrl ?? LK.na,
            AppColors.blue,
            onTap: member.facebookUrl != null
                ? () => controller.launchSafeUrl(member.facebookUrl!)
                : null,
          ),
          SizedBox(height: 16.h),
          _buildSocialItem(
            Icons.camera_alt_outlined,
            LK.instagram.tr,
            member.instagramUrl ?? LK.na,
            Colors.pink,
            onTap: member.instagramUrl != null
                ? () => controller.launchSafeUrl(member.instagramUrl!)
                : null,
          ),
          SizedBox(height: 16.h),
          _buildSocialItem(
            Icons.chat_bubble_outline,
            LK.whatsapp.tr,
            member.whatsappUrl ?? LK.na,
            AppColors.green,
            onTap: member.whatsappUrl != null
                ? () => controller.launchSafeUrl(member.whatsappUrl!)
                : null,
          ),
          SizedBox(height: 16.h),
          _buildSocialItem(
            Icons.alternate_email,
            LK.twitterX.tr,
            member.twitterUrl ?? LK.na,
            AppColors.black,
            onTap: member.twitterUrl != null
                ? () => controller.launchSafeUrl(member.twitterUrl!)
                : null,
          ),
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
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  handle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 1.w,
        ),
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
          if (title != null) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18.sp, color: AppColors.primary),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title!,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
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

class _EducationSection extends StatelessWidget {
  const _EducationSection({required this.controller});
  final FamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: LK.educationDetails.tr,
      icon: Icons.school_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.memberEducations.asMap().entries.map((entry) {
          final index = entry.key;
          final edu = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        edu.qualification,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (edu.isHighest) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.15),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          LK.highest.tr,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (edu.institute.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildColumnItem(LK.instituteNameLabel.tr, edu.institute),
                ],
                if (edu.description.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildColumnItem(LK.description.tr, edu.description),
                ],
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (edu.passingYear.isNotEmpty)
                      Expanded(
                        child: _buildColumnItem(
                          LK.passingYear.tr,
                          edu.passingYear,
                        ),
                      ),
                    if (edu.percentage.isNotEmpty)
                      Expanded(
                        child: _buildColumnItem(
                          LK.percentage.tr,
                          '${edu.percentage}%',
                        ),
                      ),
                    if (edu.grade.isNotEmpty)
                      Expanded(child: _buildColumnItem(LK.grade.tr, edu.grade)),
                  ],
                ),
                if (index != controller.memberEducations.length - 1)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Divider(
                      height: 1.h,
                      color: AppColors.grey.withValues(alpha: 0.05),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OccupationSection extends StatelessWidget {
  const _OccupationSection({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    Widget? getFieldWidget(
      String label,
      String? value, {
      bool isExpandable = false,
    }) {
      if (value == null ||
          value.isEmpty ||
          value == LK.na.tr ||
          value == 'null') {
        return null;
      }
      return _buildColumnItem(label, value, isExpandable: isExpandable);
    }

    final wType = getFieldWidget(
      LK.occupationTypeLabel.tr,
      member.occupationTypeName,
    );
    final wName = getFieldWidget(LK.occupationColon.tr, member.occupationName);
    final wJobPos = getFieldWidget(
      LK.jobPositionLabel.tr,
      member.jobPositionName,
    );
    final wOtherJobPos = getFieldWidget(
      LK.otherJobPositionLabel.tr,
      member.otherJobPosition,
    );
    final wOtherOcc = getFieldWidget(
      LK.otherOccupationLabel.tr,
      member.otherOccupation,
      isExpandable: true,
    );
    final wCompany = getFieldWidget(
      LK.companyNameLabel.tr,
      member.companyName,
      isExpandable: true,
    );

    final wBusiness = getFieldWidget(
      LK.businessName.tr,
      member.businessName,
      isExpandable: true,
    );
    final wDesc = getFieldWidget(
      LK.occupationDescriptionLabel.tr,
      member.occupationDescription,
      isExpandable: true,
    );
    final wAddr1 = getFieldWidget(
      LK.occupationAddressLine1Label.tr,
      member.occupationAddressLine1,
      isExpandable: true,
    );
    final wAddr2 = getFieldWidget(
      LK.occupationAddressLine2Label.tr,
      member.occupationAddressLine2,
      isExpandable: true,
    );

    final wState = getFieldWidget(LK.state.tr, member.occupationStateName);
    final wDistrict = getFieldWidget(
      LK.district.tr,
      member.occupationDistrictName,
    );
    final wTaluka = getFieldWidget(LK.taluka.tr, member.occupationTalukaName);
    final wArea = getFieldWidget(LK.area.tr, member.occupationAreaName);
    final wLandmark = getFieldWidget(
      LK.landmarkLabel.tr,
      member.occupationLandmark,
      isExpandable: true,
    );
    final wPincode = getFieldWidget(LK.pincode.tr, member.occupationPincode);

    final rows = <Widget>[];

    void addPair(Widget? w1, Widget? w2) {
      if (w1 != null && w2 != null) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: w1),
                SizedBox(width: 12.w),
                Expanded(child: w2),
              ],
            ),
          ),
        );
      } else if (w1 != null) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: w1)],
            ),
          ),
        );
      } else if (w2 != null) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: w2)],
            ),
          ),
        );
      }
    }

    void addSingle(Widget? w) {
      if (w != null) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: w,
          ),
        );
      }
    }

    addPair(wType, wName);
    addPair(wJobPos, wOtherJobPos);
    addSingle(wOtherOcc);
    addSingle(wCompany);

    addSingle(wBusiness);
    addSingle(wDesc);
    addSingle(wAddr1);
    addSingle(wAddr2);

    addPair(wState, wDistrict);
    addPair(wTaluka, wArea);

    addSingle(wLandmark);
    addSingle(wPincode);

    if (rows.isEmpty) return SizedBox.shrink();

    return _SectionContainer(
      title: LK.occupationProfile.tr,
      icon: Icons.business_center_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildColumnItem(
    String label,
    String value, {
    bool isExpandable = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.replaceAll(':', ''),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
        ),
        SizedBox(height: 2.h),
        isExpandable
            ? ExpandableText(
                text: value,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              )
            : Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
      ],
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final VoidCallback? onTap;
  final bool isUnderline;
  final String? prefixText;
  final TextStyle? prefixStyle;

  const ExpandableText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 2,
    this.onTap,
    this.isUnderline = false,
    this.prefixText,
    this.prefixStyle,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: widget.prefixText != null ? '${widget.prefixText}: ' : '',
          style: widget.prefixStyle ?? widget.style,
          children: [TextSpan(text: widget.text, style: widget.style)],
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: widget.maxLines,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final exceeds = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: widget.onTap,
              child: Text.rich(
                TextSpan(
                  text: widget.prefixText != null
                      ? '${widget.prefixText}: '
                      : '',
                  style: widget.prefixStyle ?? widget.style,
                  children: [
                    TextSpan(
                      text: widget.text,
                      style: widget.style.copyWith(
                        decoration: widget.isUnderline
                            ? TextDecoration.underline
                            : null,
                      ),
                    ),
                  ],
                ),
                maxLines: _isExpanded ? null : widget.maxLines,
                overflow: _isExpanded
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
              ),
            ),
            if (exceeds) ...[
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'less' : 'more...',
                  style: widget.style.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

Widget _buildColumnItem(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
      ),
      SizedBox(height: 2.h),
      Text(
        value,
        overflow: TextOverflow.clip,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    ],
  );
}
