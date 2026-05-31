import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenManager tokenManager,
    required Dio refreshDio,
    required Dio mainDio,
    required VoidCallback onAuthFailure,
  }) : _tokenManager = tokenManager,
       _refreshDio = refreshDio,
       _mainDio = mainDio,
       _onAuthFailure = onAuthFailure;
  final TokenManager _tokenManager;
  final Dio _refreshDio;
  final Dio _mainDio;
  final VoidCallback _onAuthFailure;

  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    if (!path.contains('/login') && !path.contains('/member-login') && !path.contains('/refresh-token')) {
      if (_tokenManager.hasRefreshToken && _tokenManager.isAccessTokenNearExpiry) {
        try {
          await _refreshSingleFlight(_tokenManager.refreshToken!);
        } catch (_) {}
      }
    }

    final token = _tokenManager.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    final path = err.requestOptions.path;
    if (path.contains('/login') || path.contains('/member-login')) {
      return handler.next(err);
    }
    if (path.contains('/refresh-token')) {
      _onAuthFailure();
      return handler.next(err);
    }

    final isRetry = err.requestOptions.extra['isAuthRetry'] as bool? ?? false;
    if (isRetry) {
      _onAuthFailure();
      return handler.next(err);
    }

    final refreshToken = _tokenManager.refreshToken;
    if (refreshToken == null) {
      _onAuthFailure();
      return handler.next(err);
    }

    try {
      final newToken = await _refreshSingleFlight(refreshToken);
      if (newToken != null) {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        options.extra['isAuthRetry'] = true;

        final response = await _mainDio.fetch<dynamic>(options);
        return handler.resolve(response);
      } else {
        _onAuthFailure();
      }
    } catch (e) {
      if (kDebugMode) {}
      _onAuthFailure();
    }

    handler.next(err);
  }

  Future<String?> _refreshSingleFlight(String refreshToken) async {
    final existing = _refreshCompleter;
    if (existing != null && !existing.isCompleted) return existing.future;

    final c = Completer<String?>();
    _refreshCompleter = c;

    try {
      final isMember = _tokenManager.memberId != null;
      final refreshEndpoint = isMember ? ApiEndpoints.memberRefreshToken : ApiEndpoints.refreshToken;
      
      final response = await _refreshDio.post<Map<String, dynamic>>(
        refreshEndpoint,
        data: {
          'accessToken': _tokenManager.accessToken,
          'refreshToken': refreshToken,
          'mobileNo': _tokenManager.userPhone,
        },
        options: Options(
          extra: {'retryable': true},
        ),
      );

      final data = response.data ?? {};
      final authData = data['data'] as Map<String, dynamic>? ?? {};
      final access = authData['accessToken'] as String?;
      final refresh = authData['refreshToken'] as String?;

      if (access != null && refresh != null) {
        await _tokenManager.saveTokens(
          access, 
          refresh,
          isDefaultPassword: _tokenManager.isDefaultPassword,
        );
        c.complete(access);
      } else {
        if (kDebugMode) {}
        c.complete(null);
      }
    } catch (e) {
      if (kDebugMode) {}
      c.completeError(e);
    } finally {
      _refreshCompleter = null;
    }

    return c.future;
  }
}

typedef VoidCallback = void Function();
