import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

abstract class Failure implements Exception {

  const Failure(this.message, {required this.translationKey});
  final String message;
  final String translationKey;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred'])
      : super(translationKey: LK.errorServer);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection'])
      : super(translationKey: LK.errorNoInternet);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access'])
      : super(translationKey: LK.errorUnauthorized);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Access Forbidden'])
      : super(translationKey: LK.errorUnauthorized);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out'])
      : super(translationKey: LK.errorTimeout);
}

class CertificatePinningFailure extends Failure {
  const CertificatePinningFailure([super.message = 'Certificate pinning mismatch'])
      : super(translationKey: LK.errorCertificatePinning);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message)
      : super(translationKey: LK.errorValidation);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found'])
      : super(translationKey: LK.noResultsFound);
}
