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
    return AdBannerConfig(
      enabled: json['enabled'] == true,
      placementCode: json['placementCode']?.toString().trim(),
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
    final rawInterval = json['interval'];
    int parsedInterval = defaultInterval;
    if (rawInterval is int && rawInterval > 0) {
      parsedInterval = rawInterval;
    } else if (rawInterval != null) {
      parsedInterval = int.tryParse(rawInterval.toString()) ?? defaultInterval;
    }

    return AdInListConfig(
      enabled: json['enabled'] == true,
      interval: parsedInterval,
      placementCode: json['placementCode']?.toString().trim(),
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
  ]) {
    final routeStr = (json['route']?.toString() ?? '').trim();
    final screenNameStr = (json['screenName']?.toString() ?? routeStr).trim();

    return AdScreenConfig(
      route: routeStr.startsWith('/') ? routeStr : '/$routeStr',
      screenName: screenNameStr,
      topBanner: AdBannerConfig.fromJson(json['topBanner']),
      bottomBanner: AdBannerConfig.fromJson(json['bottomBanner']),
      inList: AdInListConfig.fromJson(json['inList'], defaultInterval),
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

/// Global advertisement configuration returned by the backend.
class AdGlobalConfig {
  final bool isGloballyEnabled;
  final int defaultInListInterval;
  final Map<String, AdScreenConfig> screens;

  const AdGlobalConfig({
    required this.isGloballyEnabled,
    required this.defaultInListInterval,
    required this.screens,
  });

  /// Sensible default configuration when offline or backend API is not yet available.
  factory AdGlobalConfig.defaults() {
    return AdGlobalConfig(
      isGloballyEnabled: true,
      defaultInListInterval: 4,
      screens: {
        '/home': const AdScreenConfig(
          route: '/home',
          screenName: 'Home Screen',
          topBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'home-top',
          ),
          bottomBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'home-bottom',
          ),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/library': const AdScreenConfig(
          route: '/library',
          screenName: 'Library Categories',
          topBanner: AdBannerConfig(enabled: false),
          bottomBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'library-list',
          ),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/library-items': const AdScreenConfig(
          route: '/library-items',
          screenName: 'Library Items',
          topBanner: AdBannerConfig(enabled: false),
          bottomBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'library-detail',
          ),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/events': const AdScreenConfig(
          route: '/events',
          screenName: 'Events',
          topBanner: AdBannerConfig(enabled: false),
          bottomBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'event-list',
          ),
          inList: AdInListConfig(
            enabled: true,
            interval: 4,
            placementCode: 'event-list',
          ),
        ),
        '/event-details': const AdScreenConfig(
          route: '/event-details',
          screenName: 'Event Details',
          topBanner: AdBannerConfig(enabled: false),
          bottomBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'event-detail',
          ),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/find-member': const AdScreenConfig(
          route: '/find-member',
          screenName: 'Member Directory',
          topBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'member-directory',
          ),
          bottomBanner: AdBannerConfig(enabled: false),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/occupation-directory': const AdScreenConfig(
          route: '/occupation-directory',
          screenName: 'Occupation Directory',
          topBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'occupation-directory',
          ),
          bottomBanner: AdBannerConfig(enabled: false),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/marriage': const AdScreenConfig(
          route: '/marriage',
          screenName: 'Matrimonial Directory',
          topBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'matrimonial-directory',
          ),
          bottomBanner: AdBannerConfig(enabled: false),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/notifications': const AdScreenConfig(
          route: '/notifications',
          screenName: 'Notifications',
          topBanner: AdBannerConfig(enabled: false),
          bottomBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'notifications',
          ),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/announcements': const AdScreenConfig(
          route: '/announcements',
          screenName: 'Announcements',
          topBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'announcements',
          ),
          bottomBanner: AdBannerConfig(enabled: false),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/advertisement-list': const AdScreenConfig(
          route: '/advertisement-list',
          screenName: 'Advertisement Directory',
          topBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'advertisement-list',
          ),
          bottomBanner: AdBannerConfig(enabled: false),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
        '/other': const AdScreenConfig(
          route: '/other',
          screenName: 'General / Other',
          topBanner: AdBannerConfig(
            enabled: true,
            placementCode: 'other',
          ),
          bottomBanner: AdBannerConfig(enabled: false),
          inList: AdInListConfig(enabled: false, interval: 0),
        ),
      },
    );
  }

  factory AdGlobalConfig.emptyDefaults() {
    return const AdGlobalConfig(
      isGloballyEnabled: true,
      defaultInListInterval: 4,
      screens: {},
    );
  }

  factory AdGlobalConfig.fromJson(Map<String, dynamic> json) {
    final isGloballyEnabled = json['isGloballyEnabled'] != false;
    final defaultInterval = (json['defaultInListInterval'] is int)
        ? json['defaultInListInterval'] as int
        : (int.tryParse(json['defaultInListInterval']?.toString() ?? '') ?? 4);

    final screensMap = <String, AdScreenConfig>{};
    final rawScreens = json['screens'];
    if (rawScreens is List) {
      for (final item in rawScreens) {
        if (item is Map<String, dynamic>) {
          try {
            final config = AdScreenConfig.fromJson(item, defaultInterval);
            if (config.route.isNotEmpty) {
              screensMap[config.route.toLowerCase()] = config;
            }
          } catch (_) {
            // Skip invalid screen config item
          }
        }
      }
    }

    return AdGlobalConfig(
      isGloballyEnabled: isGloballyEnabled,
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

