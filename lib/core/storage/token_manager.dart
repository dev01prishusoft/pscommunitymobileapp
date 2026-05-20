import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

class TokenManager {
  final SecureStorageService _storage;

  final RxnString accessToken = RxnString();
  final RxnString refreshToken = RxnString();

  TokenManager(this._storage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> bootstrap() async {
    try {
      accessToken.value = await _storage.read(_accessKey);
      refreshToken.value = await _storage.read(_refreshKey);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('TokenManager.bootstrap error: $e\n$stack');
      }
      accessToken.value = null;
      refreshToken.value = null;
    }
  }

  Future<void> saveTokens(String access, String refresh) async {
    try {
      accessToken.value = access;
      refreshToken.value = refresh;
      await _storage.write(_accessKey, access);
      await _storage.write(_refreshKey, refresh);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('TokenManager.saveTokens error: $e\n$stack');
      }
    }
  }

  Future<void> clearTokens() async {
    try {
      accessToken.value = null;
      refreshToken.value = null;
      await _storage.delete(_accessKey);
      await _storage.delete(_refreshKey);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('TokenManager.clearTokens error: $e\n$stack');
      }
    }
  }

  /// True when the current session can be used or recovered by refresh.
  bool get hasToken => hasValidAccessToken || hasRefreshToken;

  /// True only when an access token exists and is not expired.
  bool get hasValidAccessToken {
    final token = accessToken.value;
    if (token == null || token.isEmpty) return false;
    return !_isJwtExpired(token);
  }

  /// Backward-compatible alias for code that checks access-token validity.
  bool get hasValidToken => hasValidAccessToken;

  /// True when a refresh token exists in memory.
  /// The server remains the source of truth for refresh-token validity.
  bool get hasRefreshToken {
    final token = refreshToken.value;
    return token != null && token.isNotEmpty;
  }

  /// True when the access token is missing, invalid, or expired.
  bool get isAccessTokenExpired {
    final token = accessToken.value;
    if (token == null || token.isEmpty) return true;
    return _isJwtExpired(token);
  }

  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      var payload = parts[1];
      final remainder = payload.length % 4;
      if (remainder != 0) {
        payload = payload.padRight(payload.length + (4 - remainder), '=');
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final jsonValue = json.decode(decoded);
      if (jsonValue is Map<String, dynamic>) return jsonValue;
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool _isJwtExpired(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) return true;

    final Object? exp = payload['exp'];
    if (exp == null) return false;

    final seconds = _expirySeconds(exp);
    if (seconds == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    );

    return DateTime.now().toUtc().isAfter(
      expiry.subtract(const Duration(seconds: 30)),
    );
  }

  static int? _expirySeconds(Object exp) {
    if (exp is int) return exp;
    if (exp is double) return exp.toInt();
    if (exp is String) return int.tryParse(exp);
    return null;
  }
}
