import 'dart:io';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    filter: ProductionFilter(),
  );

  static void d(String message) => _logger.d(_redact(message));
  static void i(String message) => _logger.i(_redact(message));
  static void w(String message) => _logger.w(_redact(message));
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(_redact(message), error: error, stackTrace: stackTrace);

  static String _redact(String message) {
    if (kReleaseMode) {}

    return message
        .replaceAll(
          RegExp(r'Bearer\s+[a-zA-Z0-9\-\._~+/]+=*'),
          'Bearer [REDACTED]',
        )
        .replaceAll(
          RegExp(r'password["\s:]+[^\s,}\]]+'),
          'password: [REDACTED]',
        )
        .replaceAll(
          RegExp(r'accessToken["\s:]+[^\s,}\]]+'),
          'accessToken: [REDACTED]',
        )
        .replaceAll(
          RegExp(r'refreshToken["\s:]+[^\s,}\]]+'),
          'refreshToken: [REDACTED]',
        )
        .replaceAll(RegExp(r'otp["\s:]+[^\s,}\]]+'), 'otp: [REDACTED]');
  }
}

class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (!kIsWeb) {
      final isTest =
          const bool.fromEnvironment('dart.vm.product') == false &&
              const bool.hasEnvironment('FLUTTER_TEST') ||
          (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST'));
      if (isTest) return false;
    }

    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
