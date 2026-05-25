import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

/// A lightweight diagnostic logger that is only enabled in debug/dev modes.
/// It tracks request durations, pagination timing, render timing, and controller lifecycles.
class DiagnosticLogger {
  DiagnosticLogger._();

  static const bool _isEnabled = kDebugMode;
  static final Map<String, Stopwatch> _timers = {};

  /// Logs generic info messages
  static void log(String message, {String? tag}) {
    if (!_isEnabled) return;
    final prefix = tag != null ? '[$tag] ' : '';
    AppLogger.d('🛠️ DIAGNOSTIC: $prefix$message');
  }

  /// Logs controller creation/disposal
  static void logLifecycle(String controllerName, String event) {
    if (!_isEnabled) return;
    AppLogger.d('♻️ LIFECYCLE: [$controllerName] $event');
  }

  /// Starts a performance timer
  static void startTimer(String timerKey) {
    if (!_isEnabled) return;
    _timers[timerKey] = Stopwatch()..start();
  }

  /// Stops a performance timer and logs the duration
  static void stopTimer(String timerKey, {String? action}) {
    if (!_isEnabled) return;
    final stopwatch = _timers.remove(timerKey);
    if (stopwatch != null) {
      stopwatch.stop();
      final suffix = action != null ? ' - $action' : '';
      AppLogger.d('⏱️ TIMING: [$timerKey] took ${stopwatch.elapsedMilliseconds}ms$suffix');
    }
  }

  /// Track active API request counts (can be hooked into interceptors)
  static int _activeRequests = 0;

  static void recordRequestStart() {
    if (!_isEnabled) return;
    _activeRequests++;
  }

  static void recordRequestEnd() {
    if (!_isEnabled) return;
    _activeRequests--;
    if (_activeRequests < 0) _activeRequests = 0;
  }

  static int get activeRequests => _activeRequests;

  /// Track pagination events
  static void logPagination(String listName, int page, int itemCount) {
    if (!_isEnabled) return;
    AppLogger.d('📄 PAGINATION: [$listName] Loaded page $page (Total items: $itemCount)');
  }
}
