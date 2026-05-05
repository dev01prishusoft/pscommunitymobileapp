import 'dart:async';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final Dio _refreshDio;
  final VoidCallback _onAuthFailure;

  AuthInterceptor({
    required TokenManager tokenManager,
    required Dio refreshDio,
    required VoidCallback onAuthFailure,
  })  : _tokenManager = tokenManager,
        _refreshDio = refreshDio,
        _onAuthFailure = onAuthFailure;

  Completer<String?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenManager.accessToken.value;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = _tokenManager.refreshToken.value;
    if (refreshToken == null) {
      _onAuthFailure();
      return handler.next(err);
    }

    try {
      final newToken = await _refreshSingleFlight(refreshToken);
      if (newToken != null) {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        
        final dio = Dio(); // Basic dio for retry
        final response = await dio.fetch(options);
        return handler.resolve(response);
      }
    } catch (e) {
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
      final response = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      
      final access = response.data['access_token'];
      final refresh = response.data['refresh_token'];
      
      if (access != null && refresh != null) {
        await _tokenManager.saveTokens(access, refresh);
        c.complete(access);
      } else {
        c.complete(null);
      }
    } catch (e) {
      c.completeError(e);
    } finally {
      _refreshCompleter = null;
    }

    return c.future;
  }
}

typedef VoidCallback = void Function();
