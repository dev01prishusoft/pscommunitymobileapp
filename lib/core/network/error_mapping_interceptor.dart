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
        final data = err.response?.data;
        String? apiMessage;
        
        if (data is Map<String, dynamic>) {
          apiMessage = data['message']?.toString() ?? data['Message']?.toString();
        }

        if (status == 401) {
          failure = UnauthorizedFailure(apiMessage ?? 'Unauthorized access');
        } else if (status == 403) {
          failure = UnauthorizedFailure(apiMessage ?? 'Access Forbidden');
        } else if (status != null && status >= 500) {
          failure = ServerFailure(apiMessage ?? 'Server error occurred');
        } else {
          failure = ServerFailure(apiMessage ?? 'Server request failed');
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
