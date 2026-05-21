import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/update/app_update_gate.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/features/splash/presentation/controllers/splash_controller.dart';

/// The animated welcome screen shown after a successful login.
/// Navigation to home is handled entirely by [SplashController].
class CommunityWelcomeSplashPage extends StatefulWidget {
  const CommunityWelcomeSplashPage({super.key});

  @override
  State<CommunityWelcomeSplashPage> createState() =>
      _CommunityWelcomeSplashPageState();
}

class _CommunityWelcomeSplashPageState
    extends State<CommunityWelcomeSplashPage>
    with SingleTickerProviderStateMixin {
  // ─── Animation ────────────────────────────────────────────────────────────

  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Ensure SplashController is active for this page
    Get.put(SplashController());

    return AppUpdateGate(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _BackgroundGradient(),
            _DecorativeCircle(top: -80, left: -80, size: 200),
            _DecorativeCircle(bottom: -100, right: -100, size: 250),
            _SplashContent(
              scaleAnim: _scaleAnim,
              fadeAnim: _fadeAnim,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Background Widgets ───────────────────────────────────────────────────────

class _BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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

// ─── Splash Content ───────────────────────────────────────────────────────────

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.scaleAnim,
    required this.fadeAnim,
  });

  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        // Single Obx that reads samaj once — no nesting
        final samaj = Get.find<SamajController>().samaj.value;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AnimatedLogo(scaleAnim: scaleAnim, samaj: samaj),
            const SizedBox(height: 32),
            _AnimatedSamajName(fadeAnim: fadeAnim, samaj: samaj),
            const SizedBox(height: 8),
            _AnimatedDivider(fadeAnim: fadeAnim),
            const SizedBox(height: 16),
            _AnimatedWelcomeText(fadeAnim: fadeAnim),
            const SizedBox(height: 60),
          ],
        );
      }),
    );
  }
}

// ─── Animated Sub-Widgets ─────────────────────────────────────────────────────

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.scaleAnim, required this.samaj});

  final Animation<double> scaleAnim;
  final Samaj? samaj;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnim,
      child: _buildLogo(),
    );
  }

  Widget _buildLogo() {
    final logoUrl = samaj?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        width: 300,
        memCacheWidth: 600,
        placeholder: (context, url) => const SizedBox(
          width: 300,
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _fallbackLogo(),
      );
    }
    return _fallbackLogo();
  }

  Widget _fallbackLogo() =>
      Image.asset('assets/images/prishusoft_logo.png', width: 300);
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          samaj?.name ?? LK.samajName.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
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
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 80.0),
        child: Row(
          children: [
            Expanded(
              child: Divider(color: AppColors.primary, thickness: 1.5),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(
                Icons.diamond_outlined,
                size: 12,
                color: AppColors.primary,
              ),
            ),
            Expanded(
              child: Divider(color: AppColors.primary, thickness: 1.5),
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
        LK.welcomesYou.tr,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
