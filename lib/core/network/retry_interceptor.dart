import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
  });

  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final bool isRetryCall =
        (options.extra['__isRetryCall__'] as bool?) ?? false;

    // Prevent recursive retry loops for calls made from within this interceptor
    if (isRetryCall) {
      return handler.next(err);
    }

    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    DioException lastError = err;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final delay = initialDelay * pow(1.5, attempt - 1);
      final random = Random();
      final jitter = Duration(milliseconds: random.nextInt(300));
      final totalDelay = delay + jitter;

      await Future<void>.delayed(totalDelay);

      try {
        final retryExtra = Map<String, dynamic>.from(options.extra);
        retryExtra['__isRetryCall__'] = true;
        retryExtra['retryAttempt'] = attempt;

        dynamic retryData = options.data;
        if (retryData is FormData) {
          retryData = retryData.clone();
        }

        final retryOptions = options.copyWith(
          data: retryData,
          extra: retryExtra,
        );

        final response = await dio.fetch<dynamic>(retryOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        lastError = retryErr;
        if (!_shouldRetry(retryErr)) {
          break;
        }
      } catch (e) {
        break;
      }
    }
    return handler.next(lastError);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    if (err.type == DioExceptionType.unknown) {
      if (err.error is SocketException ||
          err.error is TimeoutException ||
          err.error is HttpException) {
        return true;
      }
      final errStr = (err.message ?? err.error?.toString() ?? '').toLowerCase();
      if (errStr.contains('socketexception') ||
          errStr.contains('connection refused') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('network is unreachable') ||
          errStr.contains('software caused connection abort') ||
          errStr.contains('connection reset by peer')) {
        return true;
      }
    }

    final status = err.response?.statusCode;
    if (status != null && status >= 500 && status <= 599) {
      return true;
    }

    return false;
  }
}
