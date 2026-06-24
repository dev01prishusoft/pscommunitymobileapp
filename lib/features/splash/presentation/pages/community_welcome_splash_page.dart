import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/splash/presentation/controllers/splash_controller.dart';
import 'package:pscommunitymobileapp/features/update/app_update_gate.dart';

class CommunityWelcomeSplashPage extends GetView<SplashController> {
  const CommunityWelcomeSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return AppUpdateGate(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _BackgroundGradient(),
            _DecorativeCircle(top: -80, left: -80, size: 200),
            _DecorativeCircle(bottom: -100, right: -100, size: 250),
            _SplashContent(),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, AppColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    this.top,
    this.left,
    this.bottom,
    this.right,
  });

  final double size;
  final double? top;
  final double? left;
  final double? bottom;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SplashContent extends GetView<SamajController> {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashController>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => _AnimatedLogo(
              scaleAnim: splashController.scaleAnim,
              samaj: controller.samaj.value,
            ),
          ),
          SizedBox(height: 32.h),
          Obx(() {
            final samaj = controller.samaj.value;
            if (samaj == null) {
              return SizedBox(height: 116.h);
            }
            return Column(
              children: [
                _AnimatedSamajName(
                  fadeAnim: splashController.fadeAnim,
                  samaj: samaj,
                ),
                SizedBox(height: 8.h),
                _AnimatedDivider(fadeAnim: splashController.fadeAnim),
                SizedBox(height: 16.h),
                _AnimatedWelcomeText(fadeAnim: splashController.fadeAnim),
              ],
            );
          }),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.scaleAnim, required this.samaj});

  final Animation<double> scaleAnim;
  final Samaj? samaj;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scaleAnim, child: _buildLogo());
  }

  Widget _buildLogo() {
    final logoUrl = samaj?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return CachedImg(
        url: logoUrl,
        width: 300.w,
        memCacheWidth: 600,
        placeholder: (context, url) => SizedBox(
          width: 300.w,
          height: 100.h,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => SizedBox.shrink(),
      );
    }
    return SizedBox.shrink();
  }
}

class _AnimatedSamajName extends StatelessWidget {
  const _AnimatedSamajName({required this.fadeAnim, required this.samaj});

  final Animation<double> fadeAnim;
  final Samaj? samaj;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          samaj?.name ?? '',
          textAlign: TextAlign.center,
          style: AppTextStyles.displayLarge.copyWith(
            color: AppColors.navyBlue,
            letterSpacing: 0.2,
          ),
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
        padding: EdgeInsets.symmetric(horizontal: 80.0),
        child: Row(
          children: [
            Expanded(child: Divider(color: AppColors.primary, thickness: 1.5)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(
                Icons.diamond_outlined,
                size: 12,
                color: AppColors.primary,
              ),
            ),
            Expanded(child: Divider(color: AppColors.primary, thickness: 1.5)),
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
        LK.welcomesYou.tr,
        style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
      ),
    );
  }
}
