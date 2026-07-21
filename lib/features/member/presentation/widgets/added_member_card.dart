import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:url_launcher/url_launcher.dart';

class AddedMemberCard extends StatelessWidget {
  const AddedMemberCard({super.key, required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: () {
        FocusScope.of(context).unfocus();
        Get.toNamed<void>(
          AppRouter.memberProfile,
          arguments: {'memberId': member.memberId},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAvatarContainer(),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      member.fullName,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (member.approveStatus != null &&
                                      member.approveStatus!.isNotEmpty) ...[
                                    SizedBox(width: 8.w),
                                    _buildStatusBadge(member.approveStatus!),
                                  ],
                                ],
                              ),
                              SizedBox(height: 6.h),
                              _buildSubtitle(),
                              _buildOccupation(),
                              _buildLocation(),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildCallButton(),
                      ],
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

  Widget _buildAvatarContainer() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
          width: 1.5.w,
        ),
      ),
      child: MemberAvatar(
        imageUrl: member.profilePhotoFullUrl,
        gender: member.genderName,
        fallbackName: member.fullName,
        radius: 28.r,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'approved') {
      color = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFE8F5E9);
    } else if (lowerStatus == 'rejected') {
      color = const Color(0xFFC62828);
      bgColor = const Color(0xFFFFEBEE);
    } else {
      color = const Color(0xFFEF6C00);
      bgColor = const Color(0xFFFFF3E0);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 4.w),
          Text(
            status.tr,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    final List<String> parts = [];

    if (member.genderName != null && member.genderName!.isNotEmpty) {
      parts.add(member.genderName!.tr);
    }

    final ageVal = member.age;
    if (ageVal > 0) {
      parts.add('$ageVal ${LK.ageYears.tr}');
    }

    if (member.gotraName != null && member.gotraName!.isNotEmpty) {
      parts.add('${LK.gotraLabel.tr} ${member.gotraName}');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join('  •  '),
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildOccupation() {
    final occ =
        member.occupationName ??
        member.jobPositionName ??
        member.occupationTypeName;
    if (occ == null || occ.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: 13.sp,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              occ.trim(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    final loc =
        member.occupationAddressLine1 ??
        member.occupationLandmark ??
        member.occupationAreaName;
    if (loc == null || loc.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 13.sp,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              loc.trim(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton() {
    if (member.mobileNo == null || member.mobileNo!.isEmpty)
      return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () async {
          final uri = Uri(scheme: 'tel', path: member.mobileNo);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
          child: Icon(
            Icons.call_rounded,
            color: AppColors.primary,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleOnTap({super.key, required this.child, required this.onTap});

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
