import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ad_screen_config_service.dart';
import 'advertisement_card.dart';
import 'smart_ad_widget.dart';

/// A route-level wrapper that automatically renders Top or Bottom advertisement
/// banners on any screen based on backend configuration ([AdScreenConfigService]).
///
/// Features:
/// 1. 100% Zero-Code for screen developers: Even if a developer creates a brand new
///    screen and writes zero ad code, banners can be turned ON or OFF remotely from the backend.
/// 2. Keyboard-aware: Hides bottom banners automatically when the keyboard is open so
///    typing in form fields is never obstructed.
/// 3. Zero-layout-shift: If no ads are configured for the screen, the [child] widget renders
///    with zero modifications or overhead.
class DynamicAdScreenWrapper extends StatelessWidget {
  final String route;
  final Widget child;
  final bool disableAds;

  const DynamicAdScreenWrapper({
    super.key,
    required this.route,
    required this.child,
    this.disableAds = false,
  });

  @override
  Widget build(BuildContext context) {
    if (disableAds) {
      return child;
    }

    // List of system or full-screen routes that should never show automatic screen banners
    final cleanRoute = AdScreenConfigService.normalizeRoute(route);
    const excludedRoutes = {
      '/login',
      '/reset-password',
      '/post-login-splash',
      '/splash',
      '/fatal-error',
      '/network-error',
      '/app-pdf-viewer',
      '/app-web-view',
      '/library-video-player',
      '/library-image-viewer',
    };

    if (excludedRoutes.contains(cleanRoute)) {
      return child;
    }

    return Obx(() {
      final service = AdScreenConfigService.to;
      final showTop = service.shouldShowTopBanner(route);
      final showBottom = service.shouldShowBottomBanner(route);

      if (!showTop && !showBottom) {
        return child;
      }

      // Check if keyboard is visible
      final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            if (showTop)
              SafeArea(
                bottom: false,
                child: SmartAdWidget(
                  placementCode: service.getTopPlacementCode(route),
                  layout: AdLayout.banner,
                ),
              ),
            Expanded(child: child),
            if (showBottom && !keyboardVisible)
              SafeArea(
                top: false,
                child: SmartAdWidget(
                  placementCode: service.getBottomPlacementCode(route),
                  layout: AdLayout.banner,
                ),
              ),
          ],
        ),
      );
    });
  }
}

