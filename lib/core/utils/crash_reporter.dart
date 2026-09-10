import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashReporter {
  const CrashReporter._();

  static void recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {}
  }

  static void log(String message) {
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }
}
