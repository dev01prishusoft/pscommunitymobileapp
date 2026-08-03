import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/family/controllers/family_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/full_screen_image_viewer.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/family/pages/member_profile_page.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';

class FromPageOccupation extends StatefulWidget {
  const FromPageOccupation({super.key});

  @override
  State<FromPageOccupation> createState() => _FromPageOccupationState();
}

class _FromPageOccupationState extends State<FromPageOccupation> {
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
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(title: Text(LK.memberDetails.tr)),
        body: Obx(
          () => AppStateView(
            state: _controller.memberDetailState.value,
            onRetry: () => _controller.loadMemberDetails(_memberId),
            child: _ProfileContent(),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: AppPrimaryButton(
            text: LK.viewProfile.tr,
            onPressed: () {
              Get.toNamed<void>(
                AppRouter.memberProfile,
                arguments: {'memberId': _memberId},
              );
            },
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
      physics: BouncingScrollPhysics(),
      child: Column(
        spacing: 10.h,
        children: [
          _ProfileHeader(member: member),
          _MemberDetailsSection(member: member, controller: controller),
          _OccupationSection(member: member),
          _SocialMediaSection(member: member, controller: controller),
          SizedBox(height: 100.h),
        ],
      ).paddingSymmetric(horizontal: 16.w, vertical: 10.h),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
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
            child: Text(
              member.fullName,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
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
          _buildGridItem(
            Icons.mail_outline,
            LK.email.tr,
            controller.formatEmail(member),
            isExpandable: true,
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
