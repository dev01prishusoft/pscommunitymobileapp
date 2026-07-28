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

class CommunityWelcomeSplashPage extends StatefulWidget {
  const CommunityWelcomeSplashPage({super.key});

  @override
  State<CommunityWelcomeSplashPage> createState() =>
      _CommunityWelcomeSplashPageState();
}

class _CommunityWelcomeSplashPageState extends State<CommunityWelcomeSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _animController.forward();
    Get.put(SplashController());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SamajController>(
      builder: (controller) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => _AnimatedLogo(
                  scaleAnim: _scaleAnim,
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
                    _AnimatedSamajName(fadeAnim: _fadeAnim, samaj: samaj),
                    SizedBox(height: 8.h),
                    _AnimatedDivider(fadeAnim: _fadeAnim),
                    SizedBox(height: 16.h),
                    _AnimatedWelcomeText(fadeAnim: _fadeAnim),
                  ],
                );
              }),
              SizedBox(height: 60.h),
            ],
          ),
        );
      },
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
        fit: BoxFit.contain,
        placeholder: (context, url) => SizedBox(
          width: 300.w,
          height: 100.h,
          child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
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
            color: AppColors.black,
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
