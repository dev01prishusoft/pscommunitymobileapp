import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ad_screen_config_service.dart';
import 'advertisement_card.dart';
import 'smart_ad_widget.dart';

/// A dynamic list separator that automatically injects an advertisement card
/// every [interval] items in a `ListView.separated` or feed.
///
/// If [interval] or [placementCode] are omitted, they are automatically read
/// from the backend route configuration ([AdScreenConfigService]).
///
/// Example:
/// ```dart
/// ListView.separated(
///   itemCount: items.length,
///   itemBuilder: (ctx, i) => CategoryCard(items[i]),
///   separatorBuilder: (ctx, i) => DynamicAdSeparator(index: i),
/// )
/// ```
class DynamicAdSeparator extends StatelessWidget {
  final int index;
  final int? interval;
  final String? placementCode;
  final Widget? regularSeparator;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final AdLayout layout;

  const DynamicAdSeparator({
    super.key,
    required this.index,
    this.interval,
    this.placementCode,
    this.regularSeparator,
    this.padding,
    this.height,
    this.layout = AdLayout.card,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final inListConfig = AdScreenConfigService.to.getInListConfig(currentRoute);

    // If explicit interval is given, use it; otherwise check backend config
    final isEnabled = inListConfig?.enabled ?? (interval != null && interval! > 0);
    if (!isEnabled) {
      return regularSeparator ?? const SizedBox.shrink();
    }

    final effectiveInterval = interval ?? (inListConfig?.interval ?? 4);
    if (effectiveInterval <= 0) {
      return regularSeparator ?? const SizedBox.shrink();
    }

    // Check if current item index qualifies for an ad injection
    final isAdSlot = (index + 1) % effectiveInterval == 0;
    if (!isAdSlot) {
      return regularSeparator ?? const SizedBox.shrink();
    }

    final code = placementCode ??
        inListConfig?.placementCode ??
        '${AdScreenConfigService.normalizeRoute(currentRoute).replaceAll('/', '')}-infeed';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (regularSeparator != null) regularSeparator!,
        SmartAdWidget(
          placementCode: code,
          layout: layout,
          height: height,
          padding: padding,
        ),
        if (regularSeparator != null) regularSeparator!,
      ],
    );
  }
}

