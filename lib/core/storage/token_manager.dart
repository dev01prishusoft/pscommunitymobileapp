import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

class TokenPair {
  final String? accessToken;
  final String? refreshToken;

  const TokenPair({this.accessToken, this.refreshToken});
}

class TokenManager {
  final SecureStorageService _storage;

  final Rx<TokenPair> authState = const TokenPair().obs;

  TokenManager(this._storage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> bootstrap() async {
    try {
      final results = await Future.wait([
        _storage.read(_accessKey),
        _storage.read(_refreshKey),
      ]);
      authState.value = TokenPair(accessToken: results[0], refreshToken: results[1]);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('TokenManager.bootstrap error: $e\n$stack');
      }
      authState.value = const TokenPair();
    }
  }

  Future<void> saveTokens(String access, String refresh) async {
    try {
      await Future.wait([
        _storage.write(_accessKey, access),
        _storage.write(_refreshKey, refresh),
      ]);
      authState.value = TokenPair(accessToken: access, refreshToken: refresh);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('TokenManager.saveTokens error: $e\n$stack');
      }
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(_accessKey),
        _storage.delete(_refreshKey),
      ]);
      authState.value = const TokenPair();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('TokenManager.clearTokens error: $e\n$stack');
      }
      rethrow;
    }
  }

  Stream<bool> get isLoggedInStream => authState.stream.map((pair) {
    if (pair.accessToken == null || pair.accessToken!.isEmpty) return false;
    return !_isJwtExpired(pair.accessToken!);
  }).distinct();

  String? get accessToken => authState.value.accessToken;
  String? get refreshToken => authState.value.refreshToken;

  /// True when the current session can be used or recovered by refresh.
  bool get hasToken => hasValidAccessToken || hasRefreshToken;

  /// True only when an access token exists and is not expired.
  bool get hasValidAccessToken {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return false;
    return !_isJwtExpired(token);
  }

  /// Backward-compatible alias for code that checks access-token validity.
  bool get hasValidToken => hasValidAccessToken;

  /// True when a refresh token exists in memory.
  /// The server remains the source of truth for refresh-token validity.
  bool get hasRefreshToken {
    final token = authState.value.refreshToken;
    return token != null && token.isNotEmpty;
  }

  /// True when the access token is missing, invalid, or expired.
  bool get isAccessTokenExpired {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return true;
    return _isJwtExpired(token);
  }

  Stream<TokenPair> get authStateStream => authState.stream;

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
