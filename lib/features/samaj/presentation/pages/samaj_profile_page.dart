import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

class SamajProfilePage extends GetView<SamajController> {
  const SamajProfilePage({super.key});

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
          LK.samajInfo.tr,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
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
                    color: AppColors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                final samaj = controller.samaj.value;
                return Column(
                  children: [
                    if (samaj?.logoUrl != null && samaj!.logoUrl.isNotEmpty)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedImg(
                            url: samaj.logoUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.account_balance,
                        size: 60,
                        color: AppColors.navyBlue,
                      ),
                    SizedBox(height: 16.h),
                    Text(
                      samaj?.name ?? LK.samajName.tr,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      LK.samajSubtitle.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }),
            ),
            _buildTimelineItem(
              context,
              title: LK.bankAccounts.tr,
              icon: Icons.account_balance,
              iconColor: AppColors.deepGreen,
              onTap: () => Get.toNamed<void>(AppRouter.bankDetails),
              isLast: true,
              isGreen: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLast = false,
    bool isGreen = false,
  }) {
    return Column(
      children: [
        Container(width: 1.w, height: 40.h, color: AppColors.grey.shade300),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isGreen ? AppColors.lightGreen : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                    color: isGreen
                        ? AppColors.lightGreen
                        : AppColors.primary.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isGreen ? AppColors.deepGreen : AppColors.deepBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.white, size: 24),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                if (!isGreen)
                  Text(
                    LK.view.tr,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right,
                  color: isGreen ? AppColors.deepGreen : AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
