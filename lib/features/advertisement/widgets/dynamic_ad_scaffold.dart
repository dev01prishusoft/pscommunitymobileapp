import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/advertisement_controller.dart';
import '../services/ad_screen_config_service.dart';
import 'advertisement_card.dart';
import 'smart_ad_widget.dart';

/// A body wrapper that injects Top and/or Bottom advertisement banners
/// INSIDE the Scaffold body (below AppBar, above bottomNavigationBar).
class DynamicAdBody extends StatefulWidget {
  final Widget child;
  final String? route;
  final bool disableTopAd;
  final bool disableBottomAd;

  const DynamicAdBody({
    super.key,
    required this.child,
    this.route,
    this.disableTopAd = false,
    this.disableBottomAd = false,
  });

  @override
  State<DynamicAdBody> createState() => _DynamicAdBodyState();
}

class _DynamicAdBodyState extends State<DynamicAdBody> {
  late final String _cleanRoute;
  bool _prefetchTriggered = false;

  @override
  void initState() {
    super.initState();
    // Compute the route once — it never changes for a given widget instance.
    _cleanRoute = AdScreenConfigService.normalizeRoute(
      widget.route ?? Get.currentRoute,
    );
    // Eagerly trigger infeed (in-list) ad pre-fetch exactly once per mount,
    // outside of any reactive Obx builder to avoid repeated callbacks.
    _scheduleInfeedPrefetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // On first dependency resolution we can safely read ModalRoute.
    if (!_prefetchTriggered) {
      final modalRouteName = ModalRoute.of(context)?.settings.name;
      if (modalRouteName != null && _cleanRoute.isEmpty) {
        // Re-compute with modal route name if initState had an empty route
        final routeFromModal = AdScreenConfigService.normalizeRoute(modalRouteName);
        _triggerInfeedPrefetch(routeFromModal);
      }
      _prefetchTriggered = true;
    }
  }

  void _scheduleInfeedPrefetch() {
    if (_cleanRoute.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _triggerInfeedPrefetch(_cleanRoute);
    });
  }

  void _triggerInfeedPrefetch(String routeKey) {
    if (routeKey.isEmpty) return;
    final service = AdScreenConfigService.to;
    final inListConfig = service.getInListConfig(routeKey);
    if (inListConfig != null && inListConfig.enabled) {
      final inListCode = inListConfig.placementCode ??
          '${routeKey.replaceAll('/', '')}-infeed';
      if (Get.isRegistered<AdvertisementController>()) {
        Get.find<AdvertisementController>().fetchAdsByCode(inListCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cleanRoute.isEmpty) return widget.child;

    return Obx(() {
      final service = AdScreenConfigService.to;
      final showTop = !widget.disableTopAd && service.shouldShowTopBanner(_cleanRoute);
      final showBottom =
          !widget.disableBottomAd && service.shouldShowBottomBanner(_cleanRoute);

      if (!showTop && !showBottom) {
        return widget.child;
      }

      final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
      final topCode = service.getTopPlacementCode(_cleanRoute);
      final bottomCode = service.getBottomPlacementCode(_cleanRoute);

      return Column(
        children: [
          if (showTop)
            SmartAdWidget(
              placementCode: topCode,
              layout: AdLayout.banner,
            ),
          Expanded(child: widget.child),
          if (showBottom && !keyboardVisible)
            SmartAdWidget(
              placementCode: bottomCode,
              layout: AdLayout.banner,
            ),
        ],
      );
    });
  }
}

/// A drop-in replacement for [Scaffold] that ensures advertisement banners
/// are strictly rendered INSIDE the Scaffold:
/// - Top banner appears BELOW the [appBar], at the very top of the body.
/// - Bottom banner appears ABOVE the [bottomNavigationBar], at the bottom of the body.
/// - Automatically hides bottom banner when the keyboard is open.
/// - Zero layout shift or overhead when no ads are enabled for the screen.
class DynamicAdScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Widget? drawer;
  final Widget? bottomSheet;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool primary;
  final String? route;
  final bool disableTopAd;
  final bool disableBottomAd;

  const DynamicAdScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.drawer,
    this.bottomSheet,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.primary = true,
    this.route,
    this.disableTopAd = false,
    this.disableBottomAd = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBody = body == null
        ? null
        : DynamicAdBody(
            route: route,
            disableTopAd: disableTopAd,
            disableBottomAd: disableBottomAd,
            child: body!,
          );

    return Scaffold(
      appBar: appBar,
      body: effectiveBody,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      drawer: drawer,
      bottomSheet: bottomSheet,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      primary: primary,
    );
  }
}

