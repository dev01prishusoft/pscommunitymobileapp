import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:math';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retryCount = options.extra['retryCount'] ?? 0;

    if (retryCount >= maxRetries || !_shouldRetry(err)) {
      return handler.next(err);
    }

    options.extra['retryCount'] = retryCount + 1;
    
    // Exponential backoff with jitter
    final delay = initialDelay * pow(2, retryCount);
    final random = Random();
    final jitter = Duration(milliseconds: random.nextInt(1000));
    
    await Future.delayed(delay + jitter);

    try {
      final dio = Dio(options.toBaseOptions());
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } catch (e) {
      // If retry fails, we might end up here
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Only retry on connection errors or transient server errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.unknown) {
      return true;
    }
    
    final status = err.response?.statusCode;
    if (status != null && status >= 500) {
      return true;
    }
    
    return false;
  }
}

extension on RequestOptions {
  BaseOptions toBaseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
      contentType: contentType,
      responseType: responseType,
      extra: extra,
    );
  }
}
