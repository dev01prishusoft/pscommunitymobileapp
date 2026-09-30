import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/connectivity_service.dart';
import 'package:pscommunitymobileapp/core/services/global_network_error_service.dart';

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

    _notifyGlobalNetworkError(err, failure);

    handler.next(err.copyWith(error: failure));
  }

  void _notifyGlobalNetworkError(DioException err, Failure failure) {
    if (err.type == DioExceptionType.cancel) return;

    final options = err.requestOptions;
    final bool skipErrorScreen =
        (options.extra['skipErrorScreen'] as bool?) ??
        (options.extra['silent'] as bool?) ??
        false;

    if (skipErrorScreen) return;

    if (!Get.isRegistered<GlobalNetworkErrorService>()) return;

    final globalService = GlobalNetworkErrorService.to;

    if (failure is TimeoutFailure) {
      globalService.handleNetworkError(
        type: NetworkErrorType.timeout,
        message: failure.message,
      );
    } else if (failure is ServerFailure) {
      final status = err.response?.statusCode;
      if (status != null && status >= 500) {
        globalService.handleNetworkError(
          type: NetworkErrorType.serverDown,
          message: failure.message,
        );
      }
    } else if (failure is NetworkFailure ||
        err.type == DioExceptionType.connectionError) {
      if (Get.isRegistered<ConnectivityService>()) {
        Get.find<ConnectivityService>().hasConnection().then((hasNet) {
          globalService.handleNetworkError(
            type: hasNet
                ? NetworkErrorType.serverDown
                : NetworkErrorType.noInternet,
            message: failure.message,
          );
        });
      } else {
        globalService.handleNetworkError(
          type: NetworkErrorType.noInternet,
          message: failure.message,
        );
      }
    }
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
