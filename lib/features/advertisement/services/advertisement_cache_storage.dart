import '../models/ad_placement.dart';
import '../models/advertisement.dart';

class _CacheEntry {
  final List<Advertisement> advertisements;
  final DateTime cachedAt;

  _CacheEntry({
    required this.advertisements,
    required this.cachedAt,
  });

  bool isExpired(Duration ttl) {
    return DateTime.now().isAfter(cachedAt.add(ttl));
  }
}

class AdvertisementCacheStorage {
  static const Duration defaultTtl = Duration(minutes: 5);

  final Map<String, _CacheEntry> _cache = {};

  String _generateKey(int samajId, AdPlacement placement) {
    return '${samajId}_${placement.code}';
  }

  List<Advertisement>? get(
    int samajId,
    AdPlacement placement, {
    Duration ttl = defaultTtl,
    bool allowStaleIfOffline = false,
  }) {
    final key = _generateKey(samajId, placement);
    final entry = _cache[key];
    if (entry == null) return null;

    if (!allowStaleIfOffline && entry.isExpired(ttl)) {
      _cache.remove(key);
      return null;
    }

    // Filter out campaigns that have reached endAtUtc
    final validAds = entry.advertisements
        .where((ad) => !ad.isExpired)
        .toList();

    if (validAds.isEmpty) {
      _cache.remove(key);
      return null;
    }

    return validAds;
  }

  void set(
    int samajId,
    AdPlacement placement,
    List<Advertisement> advertisements,
  ) {
    final validAds = advertisements.where((ad) => !ad.isExpired).toList();
    final key = _generateKey(samajId, placement);
    _cache[key] = _CacheEntry(
      advertisements: validAds,
      cachedAt: DateTime.now(),
    );
  }

  void invalidatePlacement(int samajId, AdPlacement placement) {
    _cache.remove(_generateKey(samajId, placement));
  }

  void clear() {
    _cache.clear();
  }
}
