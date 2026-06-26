import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';

class AddedMemberCard extends StatelessWidget {
  const AddedMemberCard({
    super.key,
    required this.member,
  });

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.white,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed<void>(
            AppRouter.memberProfile,
            arguments: {'memberId': member.memberId},
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getFullName(),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (member.approveStatus != null && member.approveStatus!.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          _buildStatusChip(member.approveStatus!),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    _buildSubtitle(),
                    SizedBox(height: 6.h),
                    _buildLocation(),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return MemberAvatar(
      imageUrl: member.profilePhotoFullUrl,
      gender: member.genderName,
      fallbackName: _getFullName(),
      radius: 28.r,
    );
  }

  String _getFullName() {
    final parts = [
      member.firstName,
      member.middleName,
      member.lastName,
    ].where((p) => p != null && p.isNotEmpty).toList();
    
    if (parts.isEmpty) return 'Unknown Member';
    return parts.join(' ');
  }

  Widget _buildSubtitle() {
    final List<String> parts = [];
    
    if (member.genderName != null && member.genderName!.isNotEmpty) {
      parts.add(member.genderName!);
    }
    
    if (member.dateOfBirth != null && member.dateOfBirth!.isNotEmpty) {
      final dob = DateTime.tryParse(member.dateOfBirth!);
      if (dob != null) {
        final now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || 
            (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
        if (age >= 0) {
          parts.add('$age વર્ષ');
        }
      }
    } else if (member.apiAge != null && member.apiAge! > 0) {
      parts.add('${member.apiAge} વર્ષ');
    }

    final occ = member.occupationName ?? member.jobPositionName;
    if (occ != null && occ.isNotEmpty) {
      parts.add(occ);
    }

    if (parts.isEmpty) return SizedBox.shrink();

    return Text(
      parts.join(' • '),
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.mutedForeground,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation() {
    final loc = member.occupationAddressLine1 ?? member.occupationLandmark;
    if (loc == null || loc.trim().isEmpty) return SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: 14,
          color: AppColors.primary,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            loc.trim(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'approved') {
      bgColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green;
    } else if (lowerStatus == 'rejected') {
      bgColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red;
    } else {
      bgColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.tr,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
