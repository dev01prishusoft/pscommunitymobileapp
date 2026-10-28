import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
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
  final double? height;

  const AdPlacementSlot({
    super.key,
    required this.placement,
    this.layout = AdLayout.card,
    this.limit,
    this.padding,
    this.height,
  });

  @override
  State<AdPlacementSlot> createState() => _AdPlacementSlotState();
}

class _AdPlacementSlotState extends State<AdPlacementSlot> with RouteAware {
  AdvertisementController? _controller;

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      AppRouter.routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // When returning back to this screen from a pushed route, re-validate ads in background
    _fetchAds();
  }

  void _fetchAds() {
    if (Get.isRegistered<ModulePermissionService>()) {
      if (!ModulePermissionService.to.isAccessible(AppModule.advertisement)) {
        return;
      }
    }
    if (Get.isRegistered<AdvertisementController>()) {
      _controller = Get.find<AdvertisementController>();
      final limit = widget.limit ?? 5;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller?.fetchPlacementAds(widget.placement, limit: limit);
        }
      });
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

      final cardHeight = widget.height ?? 130.h;
      final displayAds = ads.take(widget.limit ?? 5).toList();

      final content = AdBannerCarousel(
        advertisements: displayAds,
        placement: widget.placement,
        layout: widget.layout,
        height: cardHeight,
      );

      return Padding(
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        child: content,
      );
    });
  }
}
