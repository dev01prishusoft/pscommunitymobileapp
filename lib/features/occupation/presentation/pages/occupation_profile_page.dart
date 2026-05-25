import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/occupation/presentation/controllers/occupation_controller.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';

class OccupationProfilePage extends StatefulWidget {
  const OccupationProfilePage({super.key});

  @override
  State<OccupationProfilePage> createState() => _OccupationProfilePageState();
}

class _OccupationProfilePageState extends State<OccupationProfilePage> {
  final controller = Get.find<OccupationController>();
  int _occupationId = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('occupationId')) {
      _occupationId = args['occupationId'] as int;
      controller.loadOccupationDetails(_occupationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.occupationProfile.tr,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary),
        ),
        centerTitle: false,
      ),
      body: Obx(
        () => AppStateView(
          state: controller.detailsState.value,
          onRetry: () => controller.loadOccupationDetails(_occupationId),
          child: _buildProfileContent(),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final occ = controller.selectedOccupation.value;
    if (occ == null) return SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                  child: occ.logoUrl != null && occ.logoUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedImg(
                            url: occ.logoUrl!,
                            memCacheHeight: 300,
                            memCacheWidth: 300,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.mutedForeground,
                        ),
                ),
                SizedBox(height: 16.h),
                Text(
                  occ.memberName ?? LK.na.tr,
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${occ.name} ${LK.at.tr} ${occ.companyName ?? LK.na.tr}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business_center,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      LK.occupationLabel.tr,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(),
                ),
                _buildDetailRow(
                  Icons.person_outline,
                  LK.occupationTypeLabel.tr,
                  occ.occupationType ?? LK.na.tr,
                ),
                _buildDetailRow(
                  Icons.business_center_outlined,
                  LK.occupationLabel.tr,
                  occ.name,
                ),
                _buildDetailRow(
                  Icons.apartment,
                  LK.companyNameLabel.tr,
                  (occ.companyName ?? LK.na.tr),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 140.w,
                        child: Text(
                          LK.businessAddressLabel.tr,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              occ.businessAddress ?? LK.na.tr,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            if (occ.businessAddress != null)
                              GestureDetector(
                                onTap: () {
                                  _showAddressPopup(occ.businessAddress!);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    LK.showMore.tr,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _buildDetailRow(
                  Icons.phone_outlined,
                  LK.mobileColon.tr,
                  occ.mobile ?? LK.na.tr,
                ),
                _buildDetailRow(
                  Icons.description_outlined,
                  LK.descriptionLabel.tr,
                  occ.description ?? LK.na.tr,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          if (occ.memberId != null)
            ElevatedButton(
              onPressed: () {
                Get.toNamed<void>(
                  AppRouter.memberProfile,
                  arguments: {'memberId': occ.memberId},
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, color: AppColors.white),
                  SizedBox(width: 12.w),
                  Text(
                    LK.viewFullMemberProfile.tr,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: AppColors.white),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddressPopup(String address) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary),
            SizedBox(width: 10.w),
            Text(LK.fullAddress.tr),
          ],
        ),
        content: Text(
          address,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondary,
            height: 1.5.h,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(LK.close.tr, style: AppTextStyles.labelLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 12.w),
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLink ? AppColors.primary : AppColors.secondary,
                fontWeight: isLink ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          if (isLink) ...[
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
          ],
        ],
      ),
    );
  }
}
