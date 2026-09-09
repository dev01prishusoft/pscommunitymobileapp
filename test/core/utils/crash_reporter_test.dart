import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';

void main() {
  group('CrashReporter', () {
    test('recordError executes safely without throwing even without Firebase init', () {
      expect(
        () => CrashReporter.recordError(
          Exception('Test error'),
          StackTrace.current,
          reason: 'Unit test execution',
        ),
        returnsNormally,
      );
    });

    test('recordError executes safely with null stack trace and optional parameters', () {
      expect(
        () => CrashReporter.recordError(
          'String error',
          null,
        ),
        returnsNormally,
      );
    });

    test('recordError executes safely with fatal flag set', () {
      expect(
        () => CrashReporter.recordError(
          FormatException('Invalid format'),
          StackTrace.current,
          reason: 'Fatal test',
          fatal: true,
        ),
        returnsNormally,
      );
    });

    test('log executes safely without throwing even without Firebase init', () {
      expect(
        () => CrashReporter.log('Navigation event breadcrumb'),
        returnsNormally,
      );
    });
  });
}
