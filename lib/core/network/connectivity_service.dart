import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({required Connectivity connectivity})
    : _connectivity = connectivity;
  final Connectivity _connectivity;

  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    if (!result.any((r) => r != ConnectivityResult.none)) {
      return false;
    }
    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Stream<List<ConnectivityResult>> get onChange =>
      _connectivity.onConnectivityChanged.distinct();

  void dispose() {}
}
