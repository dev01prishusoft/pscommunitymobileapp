import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import '../models/advertisement_tracking_event.dart';
import '../repositories/advertisement_repository.dart';

class AdvertisementTrackingService {
  final AdvertisementRepository _repository;
  late final String sessionId;
  String? _appVersion;

  final Set<String> _trackedImpressionKeys = {};
  final List<AdvertisementTrackingEvent> _eventQueue = [];
  Timer? _flushTimer;
  bool _isFlushing = false;

  AdvertisementTrackingService(this._repository) {
    sessionId = _generateUuidV4();
    _initPackageInfo();
    _startPeriodicFlush();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {
      _appVersion = '1.0.0';
    }
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
      default:
        return 'android';
    }
  }

  static String _generateUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    // Set version to 0100 (4)
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant to 10xx (RFC 4122)
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  void recordImpression(Advertisement ad, AdPlacement placement) {
    if (ad.id <= 0 || !ad.trackEvents) return;
    final dedupeKey = '${ad.id}_${placement.code}_$sessionId';
    if (_trackedImpressionKeys.contains(dedupeKey)) {
      return;
    }
    _trackedImpressionKeys.add(dedupeKey);

    final event = AdvertisementTrackingEvent(
      clientEventId: _generateUuidV4(),
      advertisementId: ad.id,
      placement: placement.code,
      type: 'impression',
      occurredAtUtc: DateTime.now().toUtc(),
      sessionId: sessionId,
      devicePlatform: _platformName,
      appVersion: _appVersion,
      trackingToken: ad.trackingToken,
    );

    _enqueue(event);
  }

  void recordClick(
    Advertisement ad,
    AdPlacement placement, {
    String action = 'cta',
  }) {
    if (ad.id <= 0 || !ad.trackEvents) return;

    final event = AdvertisementTrackingEvent(
      clientEventId: _generateUuidV4(),
      advertisementId: ad.id,
      placement: placement.code,
      type: 'click',
      occurredAtUtc: DateTime.now().toUtc(),
      sessionId: sessionId,
      devicePlatform: _platformName,
      appVersion: _appVersion,
      trackingToken: ad.trackingToken,
      action: action,
    );

    _enqueue(event);
    // Flush immediately for click events in background without blocking
    unawaited(flush());
  }

  void _enqueue(AdvertisementTrackingEvent event) {
    _eventQueue.add(event);
    if (_eventQueue.length >= 50) {
      unawaited(flush());
    }
  }

  void _startPeriodicFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      flush();
    });
  }

  Future<void> flush() async {
    if (_isFlushing || _eventQueue.isEmpty) return;
    _isFlushing = true;

    try {
      final batch = List<AdvertisementTrackingEvent>.from(_eventQueue.take(50));
      final result = await _repository.trackEvents(batch);
      if (result.isSuccess) {
        _eventQueue.removeRange(0, batch.length);
      }
    } catch (_) {
      // Retry in next flush cycle
    } finally {
      _isFlushing = false;
    }
  }

  void clear() {
    _eventQueue.clear();
    _trackedImpressionKeys.clear();
  }

  void dispose() {
    _flushTimer?.cancel();
    _eventQueue.clear();
  }
}
