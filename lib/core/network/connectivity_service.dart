import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';

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

  Future<bool> isServerReachable() async {
    try {
      final conn = await _connectivity.checkConnectivity();
      if (!conn.any((r) => r != ConnectivityResult.none)) {
        return false;
      }

      final uri = Uri.parse(AppEnvironment.I.apiBaseUrl);
      final host = uri.host;
      if (host.isEmpty) return false;

      final lookup = await InternetAddress.lookup(host).timeout(_dnsTimeout);
      if (lookup.isEmpty || lookup[0].rawAddress.isEmpty) return false;

      final port = uri.port != 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {}
}
