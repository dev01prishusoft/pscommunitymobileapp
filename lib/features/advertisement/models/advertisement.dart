import 'ad_placement.dart';
import 'advertisement_contact.dart';
import 'advertisement_media.dart';

enum AdvertisementType {
  imageBanner,
  video,
  card;

  static AdvertisementType fromJson(dynamic value) {
    if (value == null) return AdvertisementType.imageBanner;
    if (value is int) {
      switch (value) {
        case 1:
          return AdvertisementType.imageBanner;
        case 2:
          return AdvertisementType.video;
        case 3:
          return AdvertisementType.card;
      }
    }
    final str = value.toString().toLowerCase();
    if (str.contains('video')) return AdvertisementType.video;
    if (str.contains('card')) return AdvertisementType.card;
    return AdvertisementType.imageBanner;
  }

  String toJson() {
    switch (this) {
      case AdvertisementType.imageBanner:
        return 'imageBanner';
      case AdvertisementType.video:
        return 'video';
      case AdvertisementType.card:
        return 'card';
    }
  }
}

enum ClickAction {
  inAppBrowser,
  externalBrowser,
  appDetailView,
  deepLink;

  static ClickAction fromJson(dynamic value) {
    if (value == null) return ClickAction.appDetailView;
    if (value is int) {
      switch (value) {
        case 1:
          return ClickAction.inAppBrowser;
        case 2:
          return ClickAction.externalBrowser;
        case 3:
          return ClickAction.deepLink;
        default:
          return ClickAction.appDetailView;
      }
    }
    final str = value.toString().toLowerCase().trim();
    if (str == '1' ||
        str.contains('inapp') ||
        str.contains('in-app') ||
        str.contains('in_app')) {
      return ClickAction.inAppBrowser;
    }
    if (str == '2' || str.contains('external')) {
      return ClickAction.externalBrowser;
    }
    if (str == '3' || str.contains('deep') || str.contains('dial')) {
      return ClickAction.deepLink;
    }
    return ClickAction.appDetailView;
  }

  String toJson() {
    switch (this) {
      case ClickAction.inAppBrowser:
        return 'inAppBrowser';
      case ClickAction.externalBrowser:
        return 'externalBrowser';
      case ClickAction.appDetailView:
        return 'appDetailView';
      case ClickAction.deepLink:
        return 'deepLink';
    }
  }
}

class Advertisement {
  final int id;
  final String title;
  final String? subtitle;
  final String? description;
  final AdvertisementType type;
  final AdPlacement placement;
  final ClickAction clickAction;
  final String? targetUrl;
  final String ctaLabel;
  final AdvertisementMedia media;
  final AdvertisementContact? contact;
  final String? trackingToken;
  final bool showSponsoredLabel;
  final bool trackEvents;
  final DateTime? startAtUtc;
  final DateTime? endAtUtc;

  const Advertisement({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.type,
    required this.placement,
    required this.clickAction,
    this.targetUrl,
    required this.ctaLabel,
    required this.media,
    this.contact,
    this.trackingToken,
    this.showSponsoredLabel = true,
    this.trackEvents = true,
    this.startAtUtc,
    this.endAtUtc,
  });

  bool get isExpired {
    if (endAtUtc == null) return false;
    return DateTime.now().toUtc().isAfter(endAtUtc!);
  }

  bool get isValid =>
      id > 0 &&
      title.isNotEmpty &&
      media.url.isNotEmpty &&
      !isExpired;

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    final mediaJson = json['media'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['media'] as Map)
        : <String, dynamic>{
            'url': json['mediaUrl'] ??
                json['imageUrl'] ??
                json['bannerImageUrl'] ??
                json['fileUrl'] ??
                json['videoUrl'] ??
                '',
            'thumbnailUrl': json['thumbnailUrl'] ??
                json['thumbnail'] ??
                json['thumbUrl'] ??
                json['coverImage'] ??
                json['coverImageUrl'] ??
                json['posterUrl'],
            'contentType': json['contentType'] ?? json['mimeType'],
            'width': json['width'],
            'height': json['height'],
            'durationSeconds': json['durationSeconds'],
          };

    // If media map has no thumbnail, fallback to root json keys
    if (mediaJson['thumbnailUrl'] == null &&
        mediaJson['thumbnail'] == null &&
        mediaJson['thumbUrl'] == null &&
        mediaJson['coverImageUrl'] == null &&
        mediaJson['coverImage'] == null) {
      final rootThumb = json['thumbnailUrl'] ??
          json['thumbnail'] ??
          json['thumbUrl'] ??
          json['coverImage'] ??
          json['coverImageUrl'] ??
          json['cover'] ??
          json['posterUrl'] ??
          json['poster'] ??
          json['previewUrl'] ??
          json['previewImage'] ??
          json['imageUrl'] ??
          json['bannerImageUrl'];
      if (rootThumb != null) {
        mediaJson['thumbnailUrl'] = rootThumb;
      }
    }

    final contactJson = json['contact'] is Map<String, dynamic>
        ? json['contact'] as Map<String, dynamic>
        : null;

    final placementVal = json['placement']?.toString();

    return Advertisement(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      type: AdvertisementType.fromJson(json['type'] ?? json['advertisementTypeId']),
      placement: AdPlacement.fromCode(placementVal),
      clickAction: ClickAction.fromJson(
        json['clickAction'] ??
            json['clickActionId'] ??
            json['onClickAction'] ??
            json['click_action'],
      ),
      targetUrl: json['targetUrl']?.toString(),
      ctaLabel: json['ctaLabel']?.toString() ?? 'Know More',
      media: AdvertisementMedia.fromJson(mediaJson),
      contact: contactJson != null ? AdvertisementContact.fromJson(contactJson) : null,
      trackingToken: json['trackingToken']?.toString(),
      showSponsoredLabel: json['showSponsoredLabel'] is bool
          ? json['showSponsoredLabel'] as bool
          : (json['showSponsoredLabel']?.toString().toLowerCase() != 'false'),
      trackEvents: json['trackEvents'] is bool
          ? json['trackEvents'] as bool
          : (json['trackEvents']?.toString().toLowerCase() != 'false'),
      startAtUtc: json['startAtUtc'] != null
          ? DateTime.tryParse(json['startAtUtc'].toString())?.toUtc()
          : null,
      endAtUtc: json['endAtUtc'] != null
          ? DateTime.tryParse(json['endAtUtc'].toString())?.toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      'type': type.toJson(),
      'placement': placement.code,
      'clickAction': clickAction.toJson(),
      if (targetUrl != null) 'targetUrl': targetUrl,
      'ctaLabel': ctaLabel,
      'media': media.toJson(),
      if (contact != null) 'contact': contact!.toJson(),
      if (trackingToken != null) 'trackingToken': trackingToken,
      'showSponsoredLabel': showSponsoredLabel,
      'trackEvents': trackEvents,
      if (startAtUtc != null) 'startAtUtc': startAtUtc!.toIso8601String(),
      if (endAtUtc != null) 'endAtUtc': endAtUtc!.toIso8601String(),
    };
  }
}
