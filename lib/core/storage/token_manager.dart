import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

class TokenPair {
  TokenPair({this.accessToken, this.refreshToken});
  final String? accessToken;
  final String? refreshToken;
}

class TokenManager {
  TokenManager(this._storage);
  final SecureStorageService _storage;

  final Rx<TokenPair> authState = TokenPair().obs;

  static final _accessKey = 'access_token';
  static final _refreshKey = 'refresh_token';

  Future<void> bootstrap() async {
    try {
      final results = await Future.wait([
        _storage.read(_accessKey),
        _storage.read(_refreshKey),
      ]);
      authState.value = TokenPair(
        accessToken: results[0],
        refreshToken: results[1],
      );
    } catch (e) {
      if (kDebugMode) {}
      authState.value = TokenPair();
    }
  }

  Future<void> saveTokens(String access, String refresh) async {
    try {
      await Future.wait([
        _storage.write(_accessKey, access),
        _storage.write(_refreshKey, refresh),
      ]);
      authState.value = TokenPair(accessToken: access, refreshToken: refresh);
    } catch (e) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(_accessKey),
        _storage.delete(_refreshKey),
      ]);
      authState.value = TokenPair();
    } catch (e) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  Stream<bool> get isLoggedInStream => authState.stream.map((pair) {
    if (pair.accessToken == null || pair.accessToken!.isEmpty) return false;
    return !_isJwtExpired(pair.accessToken!);
  }).distinct();

  String? get accessToken => authState.value.accessToken;
  String? get refreshToken => authState.value.refreshToken;
  bool get hasToken => hasValidAccessToken;
  bool get hasValidAccessToken {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return false;
    return !_isJwtExpired(token);
  }

  bool get hasValidToken => hasValidAccessToken;
  bool get hasRefreshToken {
    final token = authState.value.refreshToken;
    return token != null && token.isNotEmpty;
  }

  bool get isAccessTokenExpired {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return true;
    return _isJwtExpired(token);
  }

  bool get isAccessTokenNearExpiry {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return true;
    return _isJwtExpired(token, threshold: const Duration(minutes: 5));
  }

  Stream<TokenPair> get authStateStream => authState.stream;

  int? get memberId {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return null;
    final payload = _decodeJwtPayload(token);
    if (payload == null) return null;
    
    final id = payload['memberId'] ?? 
               payload['MemberId'] ?? 
               payload['nameid'] ?? 
               payload['id'] ??
               payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
               payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid'] ??
               payload['MemberID'];
               
    if (id == null) {
      // Log the payload keys to see what we actually got
      AppLogger.e('JWT Payload keys: ${payload.keys.join(", ")}');
    }

    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  String? get userPhone {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return null;
    final payload = _decodeJwtPayload(token);
    if (payload == null) return null;
    return payload['mobile']?.toString() ?? 
           payload['phone']?.toString() ?? 
           payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone']?.toString();
  }

  String? get userEmail {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return null;
    final payload = _decodeJwtPayload(token);
    if (payload == null) return null;
    return payload['email']?.toString() ?? 
           payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']?.toString();
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

  static String? _cachedAccessToken;
  static DateTime? _cachedAccessExpiry;

  static bool _isJwtExpired(String token, {Duration threshold = const Duration(seconds: 30)}) {
    if (token == _cachedAccessToken && _cachedAccessExpiry != null) {
      return DateTime.now().toUtc().isAfter(
        _cachedAccessExpiry!.subtract(threshold),
      );
    }
    final payload = _decodeJwtPayload(token);
    if (payload == null) return true;

    final Object? exp = payload['exp'];
    if (exp == null) return true;

    final seconds = _expirySeconds(exp);
    if (seconds == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    );

    _cachedAccessToken = token;
    _cachedAccessExpiry = expiry;

    return DateTime.now().toUtc().isAfter(
      expiry.subtract(threshold),
    );
  }

  static int? _expirySeconds(Object exp) {
    if (exp is int) return exp;
    if (exp is double) return exp.toInt();
    if (exp is String) return int.tryParse(exp);
    return null;
  }
}
