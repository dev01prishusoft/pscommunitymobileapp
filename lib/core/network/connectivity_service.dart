import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';

class ConnectivityService {
  ConnectivityService({required Connectivity connectivity})
    : _connectivity = connectivity;
  final Connectivity _connectivity;

  DateTime? _lastCheckTime;
  bool _lastCheckResult = false;
  static const _cacheDuration = Duration(seconds: 5);
  static const _dnsTimeout = Duration(seconds: 3);

  Future<bool> hasConnection() async {
    final now = DateTime.now();
    if (_lastCheckTime != null && now.difference(_lastCheckTime!) < _cacheDuration) {
      return _lastCheckResult;
    }

    final result = await _connectivity.checkConnectivity();
    if (!result.any((r) => r != ConnectivityResult.none)) {
      _lastCheckTime = now;
      _lastCheckResult = false;
      return false;
    }
    try {
      final host = Uri.parse(AppEnvironment.I.apiBaseUrl).host;
      final lookup = await InternetAddress.lookup(host).timeout(_dnsTimeout);
      _lastCheckResult = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _lastCheckResult = false;
    } on TimeoutException catch (_) {
      _lastCheckResult = false;
    } catch (_) {
      _lastCheckResult = false;
    }
    _lastCheckTime = now;
    return _lastCheckResult;
  }

  Stream<List<ConnectivityResult>> get onChange =>
      _connectivity.onConnectivityChanged.distinct();

  void dispose() {}
}
