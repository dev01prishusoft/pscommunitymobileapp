import 'dart:convert';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/secure_storage_service.dart';
import '../models/ad_screen_config.dart';

class AdScreenConfigService extends GetxService {
  final ApiClient? _apiClient;
  final SecureStorageService? _storageService;
  static const String _storageKey = 'ad_screen_config_cache';

  final Rx<AdGlobalConfig> config = AdGlobalConfig.defaults().obs;
  final RxBool isLoading = false.obs;

  AdScreenConfigService([this._apiClient, this._storageService]);

  static AdScreenConfigService get to {
    if (Get.isRegistered<AdScreenConfigService>()) {
      return Get.find<AdScreenConfigService>();
    }
    final client = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;
    final storage = Get.isRegistered<SecureStorageService>()
        ? Get.find<SecureStorageService>()
        : null;
    final service = AdScreenConfigService(client, storage);
    Get.put(service, permanent: true);
    return service;
  }

  Future<void> init() async {
    await _loadFromCache();
    await fetchScreenConfig();
  }

  Future<void> _loadFromCache() async {
    try {
      final storage = _storageService ??
          (Get.isRegistered<SecureStorageService>()
              ? Get.find<SecureStorageService>()
              : null);
      if (storage != null) {
        final cachedJson = await storage.read(_storageKey);
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final Map<String, dynamic> map = jsonDecode(cachedJson);
          config.value = AdGlobalConfig.fromJson(map);
        }
      }
    } catch (_) {
      // Non-fatal: fallback to defaults
    }
  }

  Future<void> fetchScreenConfig() async {
    final client = _apiClient ??
        (Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null);
    if (client == null) return;

    isLoading.value = true;
    try {
      final response = await client.get(ApiEndpoints.advertisementScreenConfig);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        printInfo(info: jsonEncode(data));
        if (data is Map<String, dynamic> && data['succeeded'] == true) {
          final rawData = data['data'];
          if (rawData is Map<String, dynamic>) {
            final parsed = AdGlobalConfig.fromJson(rawData);
            config.value = parsed;
            // Persist to storage for offline/instant startup
            try {
              final storage = _storageService ??
                  (Get.isRegistered<SecureStorageService>()
                      ? Get.find<SecureStorageService>()
                      : null);
              if (storage != null) {
                await storage.write(_storageKey, jsonEncode(parsed.toJson()));
              }
            } catch (_) {}
          }
        }
      }
    } catch (e, stack) {
      // Backend may not have implemented the endpoint yet; non-fatal fallback
      CrashReporter.recordError(
        e,
        stack,
        reason:
            'AdScreenConfigService.fetchScreenConfig failed (using cached/default config)',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Normalizes route string to ensure leading slash, no trailing slashes, and lowercase.
  static String normalizeRoute(String? route) {
    if (route == null || route.trim().isEmpty) return '';
    var cleaned = route.trim().toLowerCase();
    if (!cleaned.startsWith('/')) {
      cleaned = '/$cleaned';
    }
    while (cleaned.length > 1 && cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }

  /// Retrieves screen configuration for a given route.
  AdScreenConfig? getConfigForRoute(String? route) {
    final normalized = normalizeRoute(route);
    if (normalized.isEmpty) return null;
    return config.value.screens[normalized];
  }

  /// True if a top banner should be displayed on this screen route.
  bool shouldShowTopBanner(String? route) {
    if (!config.value.isGloballyEnabled) return false;
    final screenConfig = getConfigForRoute(route);
    return screenConfig?.topBanner.enabled ?? false;
  }

  /// True if a bottom banner should be displayed on this screen route.
  bool shouldShowBottomBanner(String? route) {
    if (!config.value.isGloballyEnabled) return false;
    final screenConfig = getConfigForRoute(route);
    return screenConfig?.bottomBanner.enabled ?? false;
  }

  /// Returns placement code for the top banner, falling back to '{route}-top'.
  String getTopPlacementCode(String? route) {
    final screenConfig = getConfigForRoute(route);
    final customCode = screenConfig?.topBanner.placementCode;
    if (customCode != null && customCode.isNotEmpty) {
      return customCode;
    }
    final clean = normalizeRoute(route).replaceAll('/', '');
    return clean.isEmpty ? 'top-banner' : '$clean-top';
  }

  /// Returns placement code for the bottom banner, falling back to '{route}-bottom'.
  String getBottomPlacementCode(String? route) {
    final screenConfig = getConfigForRoute(route);
    final customCode = screenConfig?.bottomBanner.placementCode;
    if (customCode != null && customCode.isNotEmpty) {
      return customCode;
    }
    final clean = normalizeRoute(route).replaceAll('/', '');
    return clean.isEmpty ? 'bottom-banner' : '$clean-bottom';
  }

  /// Returns in-list ad settings for a given route.
  AdInListConfig? getInListConfig(String? route) {
    if (!config.value.isGloballyEnabled) return null;
    final screenConfig = getConfigForRoute(route);
    if (screenConfig?.inList.enabled == true) {
      return screenConfig!.inList;
    }
    return null;
  }
}
