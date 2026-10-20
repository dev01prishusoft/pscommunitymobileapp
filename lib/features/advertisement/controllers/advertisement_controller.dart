import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/utils/safe_launcher.dart';
import 'package:pscommunitymobileapp/core/utils/token_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import '../repositories/advertisement_repository.dart';
import '../services/advertisement_cache_storage.dart';
import '../services/advertisement_tracking_service.dart';

class AdvertisementController extends GetxController {
  final AdvertisementRepository _repository;
  final AdvertisementCacheStorage _cacheStorage;
  final AdvertisementTrackingService _trackingService;
  final TokenManager _tokenManager;
  final ConnectivityService _connectivity;

  AdvertisementController({
    required AdvertisementRepository repository,
    required AdvertisementCacheStorage cacheStorage,
    required AdvertisementTrackingService trackingService,
    required TokenManager tokenManager,
    required ConnectivityService connectivity,
  })  : _repository = repository,
        _cacheStorage = cacheStorage,
        _trackingService = trackingService,
        _tokenManager = tokenManager,
        _connectivity = connectivity;

  final Map<AdPlacement, RxList<Advertisement>> _placementAds = {};
  final Map<AdPlacement, RxBool> _placementLoading = {};

  RxList<Advertisement> getAds(AdPlacement placement) {
    return _placementAds.putIfAbsent(placement, () => <Advertisement>[].obs);
  }

  RxBool getLoading(AdPlacement placement) {
    return _placementLoading.putIfAbsent(placement, () => false.obs);
  }

  Future<void> fetchPlacementAds(
    AdPlacement placement, {
    int? limit,
    bool forceRefresh = false,
  }) async {
    final samajId = _tokenManager.samajId ?? 0;
    final adsList = getAds(placement);
    final loading = getLoading(placement);

    // 1. Check cache first unless force refresh requested
    if (!forceRefresh) {
      final cached = _cacheStorage.get(samajId, placement);
      if (cached != null && cached.isNotEmpty) {
        adsList.assignAll(cached);
        return;
      }
    }

    loading.value = true;

    try {
      final isConnected = await _connectivity.hasConnection();
      if (!isConnected) {
        // Fallback to cache even if stale when offline
        final staleCache = _cacheStorage.get(
          samajId,
          placement,
          allowStaleIfOffline: true,
        );
        if (staleCache != null && staleCache.isNotEmpty) {
          adsList.assignAll(staleCache);
        } else {
          adsList.clear();
        }
        return;
      }

      final result = await _repository.getByPlacement(placement, limit: limit);
      if (result.isSuccess) {
        final ads = result.dataOrNull ?? [];
        adsList.assignAll(ads);
        _cacheStorage.set(samajId, placement, ads);
      } else {
        // Fallback to cache if network call fails
        final cached = _cacheStorage.get(
          samajId,
          placement,
          allowStaleIfOffline: true,
        );
        if (cached != null && cached.isNotEmpty) {
          adsList.assignAll(cached);
        } else {
          adsList.clear();
        }
      }
    } catch (_) {
      adsList.clear();
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
