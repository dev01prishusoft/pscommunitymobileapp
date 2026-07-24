import 'dart:convert';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

class TokenPair {
  TokenPair({
    this.accessToken,
    this.refreshToken,
    this.deviceUniqueId,
    this.isDefaultPassword = false,
    this.primaryColor,
    this.secondaryColor,
  });
  final String? accessToken;
  final String? refreshToken;
  final String? deviceUniqueId;
  final bool isDefaultPassword;
  final String? primaryColor;
  final String? secondaryColor;
}

class TokenManager {
  TokenManager(this._storage);
  final SecureStorageService _storage;

  final Rx<TokenPair> authState = TokenPair().obs;

  final RxString userPhoneRx = ''.obs;

  static final _accessKey = 'access_token';
  static final _refreshKey = 'refresh_token';
  static final _deviceUniqueKey = 'device_unique_id';
  static final _defaultPwdKey = 'is_default_pwd';
  static final _mobileKey = 'user_mobile';
  static final _primaryColorKey = 'primary_color';
  static final _secondaryColorKey = 'secondary_color';

  Future<void> bootstrap() async {
    try {
      final results = await Future.wait([
        _storage.read(_accessKey),
        _storage.read(_refreshKey),
        _storage.read(_defaultPwdKey),
        _storage.read(_mobileKey),
        _storage.read(_deviceUniqueKey),
        _storage.read(_primaryColorKey),
        _storage.read(_secondaryColorKey),
      ]);
      authState.value = TokenPair(
        accessToken: results[0],
        refreshToken: results[1],
        isDefaultPassword: results[2] == 'true',
        deviceUniqueId: results[4],
        primaryColor: results[5],
        secondaryColor: results[6],
      );
      userPhoneRx.value = results[3] ?? '';
    } catch (e) {
      if (kDebugMode) {}
      authState.value = TokenPair();
    }
  }

  Future<void> saveTokens(
    String access,
    String refresh, {
    bool isDefaultPassword = false,
    String? mobile,
    String? deviceUniqueId,
    String? primaryColor,
    String? secondaryColor,
  }) async {
    try {
      final futures = <Future<void>>[
        _storage.write(_accessKey, access),
        _storage.write(_refreshKey, refresh),
        _storage.write(_defaultPwdKey, isDefaultPassword.toString()),
      ];
      if (mobile != null) {
        futures.add(_storage.write(_mobileKey, mobile));
        userPhoneRx.value = mobile;
      }
      if (deviceUniqueId != null) {
        futures.add(_storage.write(_deviceUniqueKey, deviceUniqueId));
      }
      if (primaryColor != null) {
        futures.add(_storage.write(_primaryColorKey, primaryColor));
      }
      if (secondaryColor != null) {
        futures.add(_storage.write(_secondaryColorKey, secondaryColor));
      }
      await Future.wait(futures);

      authState.value = TokenPair(
        accessToken: access, 
        refreshToken: refresh,
        isDefaultPassword: isDefaultPassword,
        deviceUniqueId: deviceUniqueId ?? authState.value.deviceUniqueId,
        primaryColor: primaryColor ?? authState.value.primaryColor,
        secondaryColor: secondaryColor ?? authState.value.secondaryColor,
      );
    } catch (e) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.deleteAll();
      authState.value = TokenPair();
      userPhoneRx.value = '';
      
      AppColors.updateColors(null, null);
      Get.changeTheme(AppTheme.light);
    } catch (e) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  Stream<bool> get isLoggedInStream => authState.stream.map((pair) {
    if (pair.accessToken == null || pair.accessToken!.isEmpty) return false;
    return !_isJwtExpired(pair.accessToken!);
  }).distinct();

  Future<void> markPasswordReset() async {
    await _storage.write(_defaultPwdKey, 'false');
    authState.value = TokenPair(
      accessToken: authState.value.accessToken,
      refreshToken: authState.value.refreshToken,
      isDefaultPassword: false,
      deviceUniqueId: authState.value.deviceUniqueId,
      primaryColor: authState.value.primaryColor,
      secondaryColor: authState.value.secondaryColor,
    );
  }

  bool get isDefaultPassword => authState.value.isDefaultPassword;

  String? get accessToken => authState.value.accessToken;
  String? get refreshToken => authState.value.refreshToken;
  bool get hasToken => hasRefreshToken || hasValidAccessToken;
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
               
    if (id == null) {}

    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  int? get samajId {
    final token = authState.value.accessToken;
    if (token == null || token.isEmpty) return null;
    final payload = _decodeJwtPayload(token);
    if (payload == null) return null;
    
    final id = payload['samajId'] ?? 
               payload['SamajId'] ?? 
               payload['samajid'];
               
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  String? get userPhone {
    if (userPhoneRx.value.isNotEmpty) return userPhoneRx.value;
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
