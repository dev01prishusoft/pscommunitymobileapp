import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:math';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final int retryCount = (options.extra['retryCount'] as int?) ?? 0;

    if (retryCount >= maxRetries || !_shouldRetry(err)) {
      return handler.next(err);
    }

    // Only retry idempotent methods (GET, HEAD, PUT, DELETE) 
    // unless explicitly marked as retryable.
    final isIdempotent = const ['GET', 'HEAD', 'PUT', 'DELETE'].contains(options.method.toUpperCase());
    final bool retryable = options.extra['retryable'] as bool? ?? false;
    if (!isIdempotent && !retryable) {
      return handler.next(err);
    }

    options.extra['retryCount'] = retryCount + 1;
    
    // Exponential backoff with jitter
    final delay = initialDelay * pow(2, retryCount);
    final random = Random();
    final jitter = Duration(milliseconds: random.nextInt(1000));
    
    await Future<void>.delayed(delay + jitter);

    try {
      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      // Reject to prevent interceptor chain recursion
      return handler.reject(retryErr);
    } catch (e) {
      return handler.reject(err);
    }
  }

  bool _shouldRetry(DioException err) {
    // Only retry on connection errors or transient server errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    
    if (err.type == DioExceptionType.unknown) {
      if (err.error is SocketException || err.error is TimeoutException) {
        return true;
      }
    }
    
    final status = err.response?.statusCode;
    if (status != null && status >= 500) {
      return true;
    }
    
    return false;
  }
}
