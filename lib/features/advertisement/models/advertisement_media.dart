import 'package:pscommunitymobileapp/core/constants/app_environment.dart';

class AdvertisementMedia {
  final String url;
  final String? thumbnailUrl;
  final String? contentType;
  final int? width;
  final int? height;
  final double? durationSeconds;

  const AdvertisementMedia({
    required this.url,
    this.thumbnailUrl,
    this.contentType,
    this.width,
    this.height,
    this.durationSeconds,
  });

  bool get isVideo =>
      (contentType != null && contentType!.toLowerCase().contains('video')) ||
      url.toLowerCase().endsWith('.mp4');

  bool get hasValidImageThumbnail {
    if (thumbnailUrl == null || thumbnailUrl!.trim().isEmpty) return false;
    final lower = thumbnailUrl!.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi')) {
      return false;
    }
    return true;
  }

  /// Resolves relative URLs by appending the base URL from [AppEnvironment].
  static String resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    try {
      final baseUrl = AppEnvironment.I.apiBaseUrl;
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '$cleanBase$cleanPath';
    } catch (_) {
      return trimmed;
    }
  }

  factory AdvertisementMedia.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['url'] ?? json['mediaUrl'] ?? json['fileUrl'];
    final rawThumb = json['thumbnailUrl'] ??
        json['thumbUrl'] ??
        json['thumbnail'] ??
        json['imageUrl'] ??
        json['bannerImageUrl'];
    final resolvedThumb = rawThumb != null ? resolveUrl(rawThumb.toString()) : '';
    return AdvertisementMedia(
      url: resolveUrl(rawUrl?.toString()),
      thumbnailUrl: resolvedThumb.isNotEmpty ? resolvedThumb : null,
      contentType: json['contentType']?.toString() ?? json['mimeType']?.toString(),
      width: json['width'] is int
          ? json['width'] as int
          : int.tryParse(json['width']?.toString() ?? ''),
      height: json['height'] is int
          ? json['height'] as int
          : int.tryParse(json['height']?.toString() ?? ''),
      durationSeconds: json['durationSeconds'] is num
          ? (json['durationSeconds'] as num).toDouble()
          : double.tryParse(json['durationSeconds']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (contentType != null) 'contentType': contentType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
    };
  }
}
