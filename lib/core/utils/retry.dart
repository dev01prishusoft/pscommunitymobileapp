import 'package:pscommunitymobileapp/core/constants/failures.dart';

/// Failures worth retrying: the request may not have reached the server, or
/// the server hit a temporary fault. Validation/auth/not-found are final.
bool isTransientFailure(Object error) =>
    error is NetworkFailure ||
    error is TimeoutFailure ||
    error is ServerFailure;

/// Runs [action], retrying transient failures after each delay in [delays].
/// Rethrows the last error once the delays are exhausted, or immediately for
/// a non-transient error.
Future<T> retryTransient<T>(
  Future<T> Function() action, {
  List<Duration> delays = const [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ],
}) async {
  for (var attempt = 0; ; attempt++) {
    try {
      return await action();
    } catch (e) {
      if (!isTransientFailure(e) || attempt >= delays.length) rethrow;
      await Future<void>.delayed(delays[attempt]);
    }
  }
}
