import 'package:dio/dio.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'dart:io';

import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class NetworkExceptionMapper {
  static Failure map(dynamic error) {
    if (error is Failure) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutFailure();

        case DioExceptionType.badResponse:
          final response = error.response;
          if (response != null) {
            final statusCode = response.statusCode;
            AppLogger.e(
              'RAW API ERROR BODY (Status $statusCode): ${response.data}',
            );
            final parsedMessage = ApiErrorParser.parseMessage(response.data);

            if (statusCode == 401) {
              return UnauthorizedFailure(parsedMessage ?? 'Unauthorized access');
            } else if (statusCode == 403) {
              return ForbiddenFailure(parsedMessage ?? 'Access Forbidden');
            } else if (statusCode == 404) {
              return NotFoundFailure(parsedMessage ?? 'Resource not found');
            } else if (statusCode == 400 || statusCode == 422) {
              return ValidationFailure(parsedMessage ?? 'Validation failed');
            } else if (statusCode != null && statusCode >= 500) {
              return ServerFailure(parsedMessage ?? 'Server error occurred');
            }
            return ServerFailure(parsedMessage ?? 'Unexpected error occurred');
          }
          return ServerFailure('Invalid response from server');

        case DioExceptionType.cancel:
          return ServerFailure('Request cancelled');

        case DioExceptionType.connectionError:
          return NetworkFailure();

        case DioExceptionType.badCertificate:
          return CertificatePinningFailure();

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return NetworkFailure();
          }
          return ServerFailure(error.message ?? 'Unknown error occurred');
      }
    }

    if (error is SocketException) {
      return NetworkFailure();
    }

    return ServerFailure(error.toString());
  }
}

class ApiErrorParser {
  static String? parseMessage(dynamic data) {
    if (data == null) return null;
    
    if (data is String) {
      return data.isNotEmpty ? data : null;
    }

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data.containsKey('detail') && data['detail'] != null && data['detail'].toString().isNotEmpty) {
        return data['detail'].toString();
      }
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstErrorList = errors.values.first;
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            return firstErrorList.first.toString();
          } else if (firstErrorList is String) {
            return firstErrorList;
          }
        }
      }
      if (data.containsKey('title') && data['title'] != null && data['title'].toString().isNotEmpty) {
        return data['title'].toString();
      }
    }

    return null;
  }
}
