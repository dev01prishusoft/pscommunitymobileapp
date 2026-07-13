import 'package:flutter/material.dart';
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
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    _listeners.clear();
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

    for (var listener in _listeners) {
      listener(state);
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
  }
}
