import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/splash/presentation/controllers/splash_controller.dart';

class CommunityWelcomeSplashPage extends GetView<SplashController> {
  const CommunityWelcomeSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final samajController = Get.find<SamajController>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondary, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedLogo(scaleAnim: controller.scaleAnim),
                    SizedBox(height: 50.h),
                    Obx(() {
                      final samaj = samajController.samaj.value;
                      if (samaj == null) return SizedBox();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AnimatedSamajName(fadeAnim: controller.fadeAnim),
                          SizedBox(height: 12.h),
                          _AnimatedDivider(fadeAnim: controller.fadeAnim),
                          SizedBox(height: 20.h),
                          _AnimatedWelcomeText(fadeAnim: controller.fadeAnim),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends GetView<SamajController> {
  const _AnimatedLogo({required this.scaleAnim});
  final Animation<double> scaleAnim;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnim,
      child: Container(
        width: 200.w,
        height: 200.w,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.25),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.35),
              blurRadius: 30.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Obx(() => _buildLogo()),
      ),
    );
  }

  Widget _buildLogo() {
    final logoUrl = controller.samaj.value?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: CachedImg(
          url: logoUrl,
          width: 175.w,
          height: 175.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => SizedBox(
            width: 175.w,
            height: 175.h,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ),
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _AnimatedSamajName extends GetView<SamajController> {
  const _AnimatedSamajName({required this.fadeAnim});
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Text(
        controller.samaj.value?.name ?? '',
        textAlign: TextAlign.center,
        style: AppTextStyles.displayLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: AppColors.secondary.withValues(alpha: 0.6),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDivider extends StatelessWidget {
  const _AnimatedDivider({required this.fadeAnim});
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48.w),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1.5.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.0),
                      AppColors.white.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Icon(
                  Icons.diamond_outlined,
                  size: 13.sp,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1.5.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.white.withValues(alpha: 0.55),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedWelcomeText extends StatelessWidget {
  const _AnimatedWelcomeText({required this.fadeAnim});
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Text(
        LK.welcomesYou.tr.toUpperCase(),
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.white.withValues(alpha: 0.8),
          letterSpacing: 4.0,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: AppColors.secondary.withValues(alpha: 0.4),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
