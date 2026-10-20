class AdvertisementTrackingEvent {
  final String clientEventId;
  final int advertisementId;
  final String placement;
  final String type; // 'impression' or 'click'
  final DateTime occurredAtUtc;
  final String sessionId;
  final String devicePlatform;
  final String? appVersion;
  final String? trackingToken;
  final String? action; // 'cta', 'call', 'email'

  const AdvertisementTrackingEvent({
    required this.clientEventId,
    required this.advertisementId,
    required this.placement,
    required this.type,
    required this.occurredAtUtc,
    required this.sessionId,
    required this.devicePlatform,
    this.appVersion,
    this.trackingToken,
    this.action,
  });

  factory AdvertisementTrackingEvent.fromJson(Map<String, dynamic> json) {
    return AdvertisementTrackingEvent(
      clientEventId: json['clientEventId']?.toString() ?? '',
      advertisementId: json['advertisementId'] is int
          ? json['advertisementId'] as int
          : int.tryParse(json['advertisementId']?.toString() ?? '') ?? 0,
      placement: json['placement']?.toString() ?? '',
      type: json['type']?.toString() ?? 'impression',
      occurredAtUtc: json['occurredAtUtc'] != null
          ? DateTime.tryParse(json['occurredAtUtc'].toString())?.toUtc() ??
              DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      sessionId: json['sessionId']?.toString() ?? '',
      devicePlatform: json['devicePlatform']?.toString() ?? 'android',
      appVersion: json['appVersion']?.toString(),
      trackingToken: json['trackingToken']?.toString(),
      action: json['action']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientEventId': clientEventId,
      'advertisementId': advertisementId,
      'placement': placement,
      'type': type,
      'occurredAtUtc': occurredAtUtc.toIso8601String(),
      'sessionId': sessionId,
      'devicePlatform': devicePlatform,
      if (appVersion != null) 'appVersion': appVersion,
      if (trackingToken != null) 'trackingToken': trackingToken,
      if (action != null) 'action': action,
    };
  }
}
