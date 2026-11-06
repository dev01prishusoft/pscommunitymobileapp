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
  final int? adIndex;
  final bool repeat;
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
    this.adIndex,
    this.repeat = false,
    this.placementCode,
    this.regularSeparator,
    this.padding,
    this.height,
    this.layout = AdLayout.card,
  });

  /// Determines whether an in-list advertisement should be injected at [index].
  ///
  /// By default ([repeat] = false), the ad is shown ONLY ONCE at the specified index/slot
  /// (e.g. interval: 4 -> index 3, after 4 items; or exact [adIndex] if given)
  /// instead of repeating indefinitely across the entire list.
  static bool shouldShowAdAt(
    int index,
    int interval, {
    int? adIndex,
    bool repeat = false,
  }) {
    if (adIndex != null) {
      return index == adIndex;
    }
    if (interval <= 0) return false;
    if (repeat) {
      return (index + 1) % interval == 0;
    }
    // Single placement at the configured position
    return (index + 1) == interval;
  }

  /// Calculates the 0-based ad slot sequence number at [index].
  static int getAdSlotIndex(
    int index,
    int interval, {
    int? adIndex,
    bool repeat = false,
  }) {
    if (adIndex != null || !repeat) {
      return 0;
    }
    if (interval <= 0) return 0;
    return (index + 1) ~/ interval - 1;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRoute = route ??
        ModalRoute.of(context)?.settings.name ??
        Get.currentRoute;

    return Obx(() {
      final inListConfig =
          AdScreenConfigService.to.getInListConfig(effectiveRoute);

      // If explicit interval or adIndex is given, use it; otherwise check backend config
      // NOTE: Parentheses around the ?? RHS are required to avoid operator-precedence
      // misparse: `a ?? b || c` is `(a ?? b) || c`, NOT `a ?? (b || c)`.
      final isEnabled = inListConfig?.enabled ??
          ((interval != null && interval! > 0) ||
              (adIndex != null && adIndex! >= 0));
      if (!isEnabled) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      final effectiveInterval = interval ?? (inListConfig?.interval ?? 4);
      if (adIndex == null && effectiveInterval <= 0) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      // Check cadence
      if (!shouldShowAdAt(
        index,
        effectiveInterval,
        adIndex: adIndex,
        repeat: repeat,
      )) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      final code = placementCode ??
          inListConfig?.placementCode ??
          "${AdScreenConfigService.normalizeRoute(effectiveRoute).replaceAll('/', '')}-infeed";

      // Check if advertisement permission is granted
      final hasPermission = !Get.isRegistered<ModulePermissionService>() ||
          ModulePermissionService.to.isAccessible(AppModule.advertisement);
      final controller = Get.isRegistered<AdvertisementController>()
          ? Get.find<AdvertisementController>()
          : null;

      if (!hasPermission || controller == null) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      final ads = controller.getAdsByCode(code);
      final loading = controller.getLoadingByCode(code);

      // If ads haven't been fetched yet and not currently loading, trigger background fetch
      if (ads.isEmpty && !loading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchAdsByCode(code);
        });
      }

      if (ads.isEmpty) {
        return regularSeparator ?? const SizedBox.shrink();
      }

      final adSlot = getAdSlotIndex(
        index,
        effectiveInterval,
        adIndex: adIndex,
        repeat: repeat,
      );
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
