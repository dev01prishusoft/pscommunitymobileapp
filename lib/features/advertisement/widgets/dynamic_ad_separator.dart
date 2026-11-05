import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/module_permission/models/app_module.dart';
import 'package:pscommunitymobileapp/core/module_permission/services/module_permission_service.dart';
import '../controllers/advertisement_controller.dart';
import '../services/ad_screen_config_service.dart';
import 'advertisement_card.dart';
import 'smart_ad_widget.dart';

/// A dynamic list separator that automatically injects an advertisement card
/// at a comfortable, non-intrusive cadence in a ListView.separated or feed.
///
/// Features:
/// 1. Symmetrical Spacing: Guarantees 100% equal top and bottom spacing around the ad.
/// 2. Smart Cadence: Prevents user fatigue by ensuring a comfortable gap between ads.
/// 3. In-feed Rotation: Rotates across available campaigns so users see fresh content.
class DynamicAdSeparator extends StatelessWidget {
  final int index;
  final String? route;
  final int? interval;
  final String? placementCode;
  final Widget? regularSeparator;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final AdLayout layout;

  const DynamicAdSeparator({
    super.key,
    required this.index,
    this.route,
    this.interval,
    this.placementCode,
    this.regularSeparator,
    this.padding,
    this.height,
    this.layout = AdLayout.card,
  });

  /// Determines whether an in-list advertisement should be injected at [index].
  ///
  /// For larger intervals (>= 5), uses standard modulo interval spacing.
  /// For smaller intervals (< 5, e.g. 2 or 3), avoids overwhelming the user by
  /// showing the 1st ad at (interval - 1) and spacing subsequent ads with a
  /// comfortable progressive gap of 5+ items.
  static bool shouldShowAdAt(int index, int interval) {
    if (interval <= 0) return false;
    if (interval >= 5) {
      return (index + 1) % interval == 0;
    }

    int currentAdIndex = interval - 1;
    const int gap = 5;
    int step = 0;
    while (currentAdIndex <= index) {
      if (currentAdIndex == index) return true;
      currentAdIndex += gap + (step ~/ 2);
      step++;
    }
    return false;
  }

  /// Calculates the 0-based ad slot sequence number at [index].
  static int getAdSlotIndex(int index, int interval) {
    if (interval <= 0) return 0;
    if (interval >= 5) {
      return (index + 1) ~/ interval - 1;
    }

    int currentAdIndex = interval - 1;
    const int gap = 5;
    int slot = 0;
    int step = 0;
    while (currentAdIndex <= index) {
      if (currentAdIndex == index) return slot;
      currentAdIndex += gap + (step ~/ 2);
      slot++;
      step++;
    }
    return slot;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRoute = route ??
        ModalRoute.of(context)?.settings.name ??
        Get.currentRoute;

    return Obx(() {
      final inListConfig =
          AdScreenConfigService.to.getInListConfig(effectiveRoute);

      // If explicit interval is given, use it; otherwise check backend config
      final isEnabled =
          inListConfig?.enabled ?? (interval != null && interval! > 0);
      if (!isEnabled) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      final effectiveInterval = interval ?? (inListConfig?.interval ?? 4);
      if (effectiveInterval <= 0) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      // Check cadence
      if (!shouldShowAdAt(index, effectiveInterval)) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      final code = placementCode ??
          inListConfig?.placementCode ??
          "${AdScreenConfigService.normalizeRoute(effectiveRoute).replaceAll('/', '')}-infeed";

      // Check if advertisement permission is granted and ads exist before adding spacing
      final controller = Get.isRegistered<AdvertisementController>()
          ? Get.find<AdvertisementController>()
          : null;
      final ads = controller?.getAdsByCode(code) ?? const [];
      final hasPermission = !Get.isRegistered<ModulePermissionService>() ||
          ModulePermissionService.to.isAccessible(AppModule.advertisement);

      if (!hasPermission || ads.isEmpty) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      final adSlot = getAdSlotIndex(index, effectiveInterval);
      final spacing = regularSeparator ?? SizedBox(height: 8.h);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          spacing,
          SmartAdWidget(
            placementCode: code,
            layout: layout,
            height: height,
            padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w),
            adIndex: adSlot,
          ),
          spacing,
        ],
      );
    });
  }
}
