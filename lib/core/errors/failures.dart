// ignore_for_file: use_super_parameters
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  Failure? get failureOrNull => isFailure ? (this as Error<T>).failure : null;
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

abstract class Failure implements Exception {
  Failure(this.message, {required this.translationKey, this.code});
  final String message;
  final String translationKey;
  final String? code;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server error occurred', String? code])
    : super(message, translationKey: LK.errorServer, code: code);
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'No internet connection', String? code])
    : super(message, translationKey: LK.errorNoInternet, code: code);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([String message = 'Unauthorized access', String? code])
    : super(message, translationKey: LK.errorUnauthorized, code: code);
}

class ForbiddenFailure extends Failure {
  ForbiddenFailure([String message = 'Access Forbidden', String? code])
    : super(message, translationKey: LK.errorUnauthorized, code: code);
}

class TimeoutFailure extends Failure {
  TimeoutFailure([String message = 'Request timed out', String? code])
    : super(message, translationKey: LK.errorTimeout, code: code);
}

class CertificatePinningFailure extends Failure {
  CertificatePinningFailure([String message = 'Certificate pinning mismatch', String? code])
    : super(message, translationKey: LK.errorCertificatePinning, code: code);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message, {String? code}) 
    : super(message, translationKey: LK.errorValidation, code: code);
}

class NotFoundFailure extends Failure {
  NotFoundFailure([String message = 'Resource not found', String? code])
    : super(message, translationKey: LK.noResultsFound, code: code);
}
