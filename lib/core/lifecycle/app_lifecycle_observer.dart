import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/utils/diagnostic_logger.dart';

/// Centralized app lifecycle observer.
/// It tracks foreground, background, inactive, and detached states.
/// Other services can register callbacks to react to lifecycle changes.
class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver._internal();

  static final AppLifecycleObserver _instance = AppLifecycleObserver._internal();

  static AppLifecycleObserver get instance => _instance;

  final List<void Function(AppLifecycleState)> _listeners = [];

  bool _isInitialized = false;

  void init() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      DiagnosticLogger.logLifecycle('AppLifecycleObserver', 'Initialized');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    _listeners.clear();
    DiagnosticLogger.logLifecycle('AppLifecycleObserver', 'Disposed');
  }

  void addListener(void Function(AppLifecycleState) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(void Function(AppLifecycleState) listener) {
    _listeners.remove(listener);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    DiagnosticLogger.log('App State changed to: ${state.name}', tag: 'Lifecycle');

    for (var listener in _listeners) {
      listener(state);
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    DiagnosticLogger.log('Low memory warning received!', tag: 'Lifecycle');
  }
}
