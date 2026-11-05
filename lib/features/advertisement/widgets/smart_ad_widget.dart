import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ad_placement.dart';
import 'ad_placement_slot.dart';
import 'advertisement_card.dart';

/// A universal, plug-and-play advertisement widget that can be placed anywhere
/// in the app with a single line of code.
///
/// Features:
/// 1. Self-contained: Handles permissions, dynamic API calling, impression tracking, and caching.
/// 2. Zero-layout-shift: Vanishes cleanly to [SizedBox.shrink] if no ads are returned or module is disabled.
/// 3. Auto-route detection: If [placementCode] and [placement] are omitted, it automatically
///    deduces the placement from the current navigation route (e.g., '/library-categories' -> 'library-categories').
///
/// Example:
/// ```dart
/// // Simplest: automatically detects screen route
/// const SmartAdWidget()
///
/// // Custom placement code
/// const SmartAdWidget(placementCode: 'library-feed-middle')
/// ```
class SmartAdWidget extends StatelessWidget {
  final String? placementCode;
  final AdPlacement? placement;
  final AdLayout layout;
  final int? limit;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final int? adIndex;

  const SmartAdWidget({
    super.key,
    this.placementCode,
    this.placement,
    this.layout = AdLayout.card,
    this.limit,
    this.padding,
    this.height,
    this.adIndex,
  });

  String _resolvePlacementCode() {
    if (placementCode != null && placementCode!.trim().isNotEmpty) {
      return placementCode!.trim();
    }
    if (placement != null) {
      return placement!.code;
    }
    // Auto-detect route name
    final currentRoute = Get.currentRoute.replaceAll('/', '').trim();
    return currentRoute.isEmpty ? 'general' : currentRoute;
  }

  @override
  Widget build(BuildContext context) {
    final code = _resolvePlacementCode();
    return AdPlacementSlot(
      placementCode: code,
      placement: placement,
      layout: layout,
      limit: limit,
      padding: padding,
      height: height,
      adIndex: adIndex,
    );
  }
}

