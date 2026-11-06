import 'package:pscommunitymobileapp/features/advertisement/services/ad_screen_config_service.dart';

/// Represents banner ad settings (Top or Bottom) for a specific screen route.
class AdBannerConfig {
  final bool enabled;
  final String? placementCode;

  const AdBannerConfig({
    required this.enabled,
    this.placementCode,
  });

  factory AdBannerConfig.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const AdBannerConfig(enabled: false);
    }

    final rawEnabled = json['enabled'] ?? json['isEnabled'] ?? json['active'];
    final isEnabled = rawEnabled == true ||
        rawEnabled == 1 ||
        rawEnabled?.toString().toLowerCase() == 'true' ||
        rawEnabled?.toString() == '1';

    final code = (json['placementCode'] ??
            json['placement_code'] ??
            json['placement'])
        ?.toString()
        .trim();

    return AdBannerConfig(
      enabled: isEnabled,
      placementCode: (code == null || code.isEmpty) ? null : code,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'placementCode': placementCode,
      };
}

/// Represents in-list / in-feed ad injection settings for a specific screen route.
class AdInListConfig {
  final bool enabled;
  final int interval;
  final String? placementCode;

  const AdInListConfig({
    required this.enabled,
    required this.interval,
    this.placementCode,
  });

  factory AdInListConfig.fromJson(dynamic json, [int defaultInterval = 4]) {
    if (json is! Map<String, dynamic>) {
      return const AdInListConfig(enabled: false, interval: 0);
    }

    final rawInterval = json['interval'] ??
        json['adInterval'] ??
        json['frequency'] ??
        json['every'];
    int parsedInterval = defaultInterval;
    if (rawInterval is int && rawInterval > 0) {
      parsedInterval = rawInterval;
    } else if (rawInterval != null) {
      parsedInterval = int.tryParse(rawInterval.toString()) ?? defaultInterval;
    }

    final rawEnabled = json['enabled'] ?? json['isEnabled'] ?? json['active'];
    final isEnabled = rawEnabled == true ||
        rawEnabled == 1 ||
        rawEnabled?.toString().toLowerCase() == 'true' ||
        rawEnabled?.toString() == '1';

    final code = (json['placementCode'] ??
            json['placement_code'] ??
            json['placement'])
        ?.toString()
        .trim();

    return AdInListConfig(
      enabled: isEnabled,
      interval: parsedInterval,
      placementCode: (code == null || code.isEmpty) ? null : code,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'interval': interval,
        'placementCode': placementCode,
      };
}

/// Configuration for a specific screen route.
class AdScreenConfig {
  final String route;
  final String screenName;
  final AdBannerConfig topBanner;
  final AdBannerConfig bottomBanner;
  final AdInListConfig inList;

  const AdScreenConfig({
    required this.route,
    required this.screenName,
    required this.topBanner,
    required this.bottomBanner,
    required this.inList,
  });

  factory AdScreenConfig.fromJson(
    Map<String, dynamic> json, [
    int defaultInterval = 4,
    String? fallbackRoute,
  ]) {
    final routeStr = (json['route'] ??
            json['path'] ??
            json['screenRoute'] ??
            json['screen_route'] ??
            fallbackRoute ??
            '')
        .toString()
        .trim();
    final normalizedRoute = AdScreenConfigService.normalizeRoute(routeStr);
    final screenNameStr = (json['screenName'] ??
            json['screen_name'] ??
            json['name'] ??
            normalizedRoute)
        .toString()
        .trim();

    final topJson = json['topBanner'] ?? json['top_banner'] ?? json['top'];
    final bottomJson =
        json['bottomBanner'] ?? json['bottom_banner'] ?? json['bottom'];
    final inListJson =
        json['inList'] ?? json['in_list'] ?? json['inFeed'] ?? json['in_feed'];

    return AdScreenConfig(
      route: normalizedRoute,
      screenName: screenNameStr.isEmpty ? normalizedRoute : screenNameStr,
      topBanner: AdBannerConfig.fromJson(topJson),
      bottomBanner: AdBannerConfig.fromJson(bottomJson),
      inList: AdInListConfig.fromJson(inListJson, defaultInterval),
    );
  }

  Map<String, dynamic> toJson() => {
        'route': route,
        'screenName': screenName,
        'topBanner': topBanner.toJson(),
        'bottomBanner': bottomBanner.toJson(),
        'inList': inList.toJson(),
      };
}

/// Global advertisement configuration returned dynamically by the backend.
/// Contains no static hardcoded screen dictionary — all screens are dynamically
/// managed via API response.
class AdGlobalConfig {
  final bool isGloballyEnabled;
  final int defaultInListInterval;
  final Map<String, AdScreenConfig> screens;

  const AdGlobalConfig({
    required this.isGloballyEnabled,
    required this.defaultInListInterval,
    required this.screens,
  });

  /// Default configuration when offline or before backend API responds.
  /// Fully dynamic: no static screens are hardcoded.
  factory AdGlobalConfig.defaults() {
    return const AdGlobalConfig(
      isGloballyEnabled: true,
      defaultInListInterval: 4,
      screens: {},
    );
  }

  /// Empty defaults.
  factory AdGlobalConfig.emptyDefaults() {
    return const AdGlobalConfig(
      isGloballyEnabled: true,
      defaultInListInterval: 4,
      screens: {},
    );
  }

  /// Dynamically parses backend API response in either List or Map format.
  factory AdGlobalConfig.fromJson(Map<String, dynamic> json) {
    final rawGloballyEnabled = json['isGloballyEnabled'] ??
        json['is_globally_enabled'] ??
        json['enabled'];
    final isGloballyEnabled = rawGloballyEnabled == null ||
        rawGloballyEnabled == true ||
        rawGloballyEnabled == 1 ||
        rawGloballyEnabled?.toString().toLowerCase() == 'true' ||
        rawGloballyEnabled?.toString() == '1';

    final rawInterval = json['defaultInListInterval'] ??
        json['default_in_list_interval'] ??
        json['interval'];
    final defaultInterval = (rawInterval is int)
        ? rawInterval
        : (int.tryParse(rawInterval?.toString() ?? '') ?? 4);

    final screensMap = <String, AdScreenConfig>{};
    final rawScreens =
        json['screens'] ?? json['screenConfigs'] ?? json['routes'];

    if (rawScreens is List) {
      for (final item in rawScreens) {
        if (item is Map<String, dynamic>) {
          try {
            final config = AdScreenConfig.fromJson(item, defaultInterval);
            if (config.route.isNotEmpty) {
              screensMap[config.route.toLowerCase()] = config;
            }
          } catch (_) {}
        }
      }
    } else if (rawScreens is Map) {
      for (final entry in rawScreens.entries) {
        final key = entry.key?.toString() ?? '';
        final val = entry.value;
        if (val is Map<String, dynamic>) {
          try {
            final config = AdScreenConfig.fromJson(val, defaultInterval, key);
            if (config.route.isNotEmpty) {
              screensMap[config.route.toLowerCase()] = config;
            }
          } catch (_) {}
        }
      }
    }

    return AdGlobalConfig(
      isGloballyEnabled: isGloballyEnabled,
      defaultInListInterval: defaultInterval,
      screens: screensMap,
    );
  }

  /// Dynamically parses a list of screen configurations from backend.
  factory AdGlobalConfig.fromList(List<dynamic> list, [int defaultInterval = 4]) {
    final screensMap = <String, AdScreenConfig>{};
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          final config = AdScreenConfig.fromJson(item, defaultInterval);
          if (config.route.isNotEmpty) {
            screensMap[config.route.toLowerCase()] = config;
          }
        } catch (_) {}
      }
    }
    return AdGlobalConfig(
      isGloballyEnabled: true,
      defaultInListInterval: defaultInterval,
      screens: screensMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'isGloballyEnabled': isGloballyEnabled,
        'defaultInListInterval': defaultInListInterval,
        'screens': screens.values.map((s) => s.toJson()).toList(),
      };
}
