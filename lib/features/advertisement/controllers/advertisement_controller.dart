import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/utils/safe_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import '../repositories/advertisement_repository.dart';
import '../services/advertisement_tracking_service.dart';

class AdvertisementController extends GetxController
    with WidgetsBindingObserver {
  final AdvertisementRepository _repository;
  final AdvertisementTrackingService _trackingService;
  final ConnectivityService _connectivity;

  AdvertisementController({
    required AdvertisementRepository repository,
    required AdvertisementTrackingService trackingService,
    required ConnectivityService connectivity,
  })  : _repository = repository,
        _trackingService = trackingService,
        _connectivity = connectivity;

  final Map<String, RxList<Advertisement>> _stringPlacementAds = {};
  final Map<String, RxBool> _stringPlacementLoading = {};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshActivePlacements();
    }
  }

  /// Refreshes all currently loaded placements in the background when app resumes
  Future<void> refreshActivePlacements() async {
    final codes = _stringPlacementAds.keys.toList();
    for (final code in codes) {
      await fetchAdsByCode(code, forceRefresh: true);
    }
  }

  RxList<Advertisement> getAds(AdPlacement placement) {
    return getAdsByCode(placement.code);
  }

  RxBool getLoading(AdPlacement placement) {
    return getLoadingByCode(placement.code);
  }

  RxList<Advertisement> getAdsByCode(String placementCode) {
    final key = placementCode.trim().toLowerCase();
    return _stringPlacementAds.putIfAbsent(key, () => <Advertisement>[].obs);
  }

  RxBool getLoadingByCode(String placementCode) {
    final key = placementCode.trim().toLowerCase();
    return _stringPlacementLoading.putIfAbsent(key, () => false.obs);
  }

  Future<void> fetchPlacementAds(
    AdPlacement placement, {
    int? limit,
    bool forceRefresh = false,
  }) async {
    return fetchAdsByCode(placement.code, limit: limit, forceRefresh: forceRefresh);
  }

  Future<void> fetchAdsByCode(
    String placementCode, {
    int? limit,
    bool forceRefresh = false,
  }) async {
    final cleanCode = placementCode.trim().toLowerCase();
    if (cleanCode.isEmpty) return;

    final adsList = getAdsByCode(cleanCode);
    final loading = getLoadingByCode(cleanCode);

    if (adsList.isEmpty) {
      loading.value = true;
    }

    try {
      final isConnected = await _connectivity.hasConnection();
      if (!isConnected) {
        return;
      }

      final fetchLimit = limit ?? 5;
      final result = await _repository.getByPlacementCode(cleanCode, limit: fetchLimit);
      if (result.isSuccess) {
        final ads = result.dataOrNull ?? [];
        adsList.assignAll(ads);
      }
    } catch (_) {
      // Non-fatal error during fetch
    } finally {
      loading.value = false;
    }
  }

  Future<Advertisement?> getAdDetail(int id) async {
    final result = await _repository.getById(id);
    if (result.isSuccess) {
      return result.dataOrNull;
    }
    return null;
  }

  void recordImpression(Advertisement ad, AdPlacement placement) {
    _trackingService.recordImpression(ad, placement);
  }

  void recordImpressionByCode(Advertisement ad, String placementCode) {
    final placement = AdPlacement.fromCode(placementCode);
    _trackingService.recordImpression(ad, placement);
  }

  Future<void> handleAdClickByCode(
    Advertisement ad,
    String placementCode, {
    String action = 'cta',
  }) async {
    final placement = AdPlacement.fromCode(placementCode);
    return handleAdClick(ad, placement, action: action);
  }

  Future<void> handleAdClick(
    Advertisement ad,
    AdPlacement placement, {
    String action = 'cta',
  }) async {
    _trackingService.recordClick(ad, placement, action: action);

    switch (ad.clickAction) {
      case ClickAction.appDetailView:
        if (Get.currentRoute != AppRouter.advertisementDetail) {
          Get.toNamed(
            AppRouter.advertisementDetail,
            arguments: {'id': ad.id, 'advertisement': ad},
          );
        }
        break;

      case ClickAction.inAppBrowser:
        if (ad.targetUrl != null && ad.targetUrl!.trim().isNotEmpty) {
          await SafeLauncher.openInAppBrowser(
            ad.targetUrl!,
            title: ad.title,
          );
        } else if (Get.currentRoute != AppRouter.advertisementDetail) {
          Get.toNamed(
            AppRouter.advertisementDetail,
            arguments: {'id': ad.id, 'advertisement': ad},
          );
        }
        break;

      case ClickAction.externalBrowser:
        if (ad.targetUrl != null && ad.targetUrl!.trim().isNotEmpty) {
          await SafeLauncher.openExternal(ad.targetUrl!);
        } else if (Get.currentRoute != AppRouter.advertisementDetail) {
          Get.toNamed(
            AppRouter.advertisementDetail,
            arguments: {'id': ad.id, 'advertisement': ad},
          );
        }
        break;

      case ClickAction.deepLink:
        await _handleDeepLinkOrDial(ad);
        break;
    }
  }

  Future<void> _handleDeepLinkOrDial(Advertisement ad) async {
    final target = ad.targetUrl?.trim();
    if (target != null && target.isNotEmpty) {
      final lower = target.toLowerCase();
      if (lower.startsWith('tel:')) {
        await SafeLauncher.open(target);
        return;
      }
      if (lower.startsWith('mailto:')) {
        await SafeLauncher.open(target);
        return;
      }
      final cleanDigits = target.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleanDigits)) {
        await SafeLauncher.open('tel:$cleanDigits');
        return;
      }
      final uri = Uri.tryParse(target);
      if (uri != null) {
        if (uri.scheme == 'http' || uri.scheme == 'https') {
          await SafeLauncher.open(target);
          return;
        } else {
          try {
            await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
            return;
          } catch (_) {
            await SafeLauncher.open(target);
            return;
          }
        }
      }
    }

    if (ad.contact != null && ad.contact!.mobile.trim().isNotEmpty) {
      await SafeLauncher.open('tel:${ad.contact!.mobile.trim()}');
      return;
    }

    if (Get.currentRoute != AppRouter.advertisementDetail) {
      Get.toNamed(
        AppRouter.advertisementDetail,
        arguments: {'id': ad.id, 'advertisement': ad},
      );
    }
  }

  Future<void> handleContactCall(Advertisement ad, AdPlacement placement) async {
    final contact = ad.contact;
    if (contact == null || contact.mobile.trim().isEmpty) return;
    _trackingService.recordClick(ad, placement, action: 'call');
    await SafeLauncher.open('tel:${contact.mobile.trim()}');
  }

  Future<void> handleContactEmail(Advertisement ad, AdPlacement placement) async {
    final contact = ad.contact;
    if (contact == null || contact.email.trim().isEmpty) return;
    _trackingService.recordClick(ad, placement, action: 'email');
    await SafeLauncher.open('mailto:${contact.email.trim()}');
  }
}
