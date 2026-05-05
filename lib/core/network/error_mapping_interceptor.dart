import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Failure failure;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        failure = const TimeoutFailure();
        break;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        if (status == 401) {
          failure = const UnauthorizedFailure();
        } else if (status == 403) {
          failure = const UnauthorizedFailure('Access Forbidden');
        } else if (status != null && status >= 500) {
          failure = const ServerFailure();
        } else {
          final msg = err.response?.data?['message'] ?? 'Server request failed';
          failure = ServerFailure(msg);
        }
        break;
      case DioExceptionType.connectionError:
        failure = const NetworkFailure();
        break;
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          failure = const NetworkFailure();
        } else {
          failure = const ServerFailure('An unexpected error occurred');
        }
        break;
      default:
        failure = const ServerFailure();
    }

    // Pass the typed failure forward as the error
    handler.next(err.copyWith(error: failure));
  }
}
