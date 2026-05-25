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
        failure = TimeoutFailure();
        break;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        final data = err.response?.data;
        String? apiMessage;

        if (data is Map<String, dynamic>) {
          apiMessage = _extractMessage(data);
        }

        if (status == 400) {
          failure = ValidationFailure(apiMessage ?? 'Validation failed');
        } else if (status == 401) {
          failure = UnauthorizedFailure(apiMessage ?? 'Unauthorized access');
        } else if (status == 403) {
          failure = ForbiddenFailure(apiMessage ?? 'Access Forbidden');
        } else if (status == 404) {
          failure = NotFoundFailure(apiMessage ?? 'Resource not found');
        } else if (status != null && status >= 500) {
          failure = ServerFailure(apiMessage ?? 'Server error occurred');
        } else {
          failure = ServerFailure(apiMessage ?? 'Server request failed');
        }
        break;
      case DioExceptionType.connectionError:
        failure = NetworkFailure(err.message ?? 'No internet connection');
        break;
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          final socketErr = err.error as SocketException;
          failure = NetworkFailure('Network Error: ${socketErr.message}');
        } else if (err.error is HandshakeException) {
          failure = CertificatePinningFailure();
        } else {
          failure = ServerFailure(
            err.message ?? 'An unexpected error occurred',
          );
        }
        break;
      default:
        failure = ServerFailure();
    }
    handler.next(err.copyWith(error: failure));
  }

  String? _extractMessage(Map<String, dynamic> data) {
    final msg =
        data['message'] ?? data['Message'] ?? data['error'] ?? data['Error'];
    if (msg is String && msg.isNotEmpty) {
      return msg;
    }
    if (msg is List && msg.isNotEmpty) {
      return msg.first.toString();
    }
    return null;
  }
}
