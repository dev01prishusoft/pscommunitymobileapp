import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/module_permission/models/app_module.dart';
import 'package:pscommunitymobileapp/core/module_permission/services/module_permission_service.dart';
import '../controllers/advertisement_controller.dart';
import '../models/ad_placement.dart';
import 'ad_banner_carousel.dart';
import 'advertisement_card.dart';

class AdPlacementSlot extends StatefulWidget {
  final AdPlacement placement;
  final AdLayout layout;
  final int? limit;
  final EdgeInsetsGeometry? padding;

  const AdPlacementSlot({
    super.key,
    required this.placement,
    this.layout = AdLayout.card,
    this.limit,
    this.padding,
  });

  @override
  State<AdPlacementSlot> createState() => _AdPlacementSlotState();
}

class _AdPlacementSlotState extends State<AdPlacementSlot> {
  AdvertisementController? _controller;
  bool _hasTrackedImpression = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ModulePermissionService>()) {
      if (!ModulePermissionService.to.isAccessible(AppModule.advertisement)) {
        return;
      }
    }
    if (Get.isRegistered<AdvertisementController>()) {
      _controller = Get.find<AdvertisementController>();
      final limit = widget.limit ?? (widget.placement == AdPlacement.homeTop ? 5 : 1);
      _controller!.fetchPlacementAds(widget.placement, limit: limit);
    }
  }

  void _checkAndTrackImpression(BuildContext context) {
    if (_hasTrackedImpression || _controller == null) return;
    final ads = _controller!.getAds(widget.placement);
    if (ads.isEmpty) return;

    // Track for non-carousel single ad cards
    if (widget.placement != AdPlacement.homeTop && ads.isNotEmpty) {
      _hasTrackedImpression = true;
      _controller!.recordImpression(ads.first, widget.placement);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (Get.isRegistered<ModulePermissionService>()) {
        final hasAccess =
            ModulePermissionService.to.isAccessible(AppModule.advertisement);
        if (!hasAccess) {
          return const SizedBox.shrink();
        }
      }

      final ads = _controller!.getAds(widget.placement);
      if (ads.isEmpty) {
        return const SizedBox.shrink();
      }

      // Schedule impression recording when slot is built and rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkAndTrackImpression(context);
        }
      });

      final content = widget.placement == AdPlacement.homeTop
          ? AdBannerCarousel(
              advertisements: ads,
              placement: widget.placement,
            )
          : AdvertisementCard(
              advertisement: ads.first,
              placement: widget.placement,
              layout: widget.layout,
            );

      return Padding(
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: content,
      );
    });
  }
}
