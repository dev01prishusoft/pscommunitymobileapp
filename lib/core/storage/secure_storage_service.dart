import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            resetOnError: true,
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
            synchronizable: false,
          ),
        );

  Future<void> write(String key, String? value) async {
    try {
      await _storage.write(key: 'ps_community_$key', value: value);
    } catch (e) {
      if (kDebugMode) print('SecureStorage write error: $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: 'ps_community_$key');
    } catch (e) {
      if (kDebugMode) print('SecureStorage read error: $e');
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: 'ps_community_$key');
    } catch (e) {
      if (kDebugMode) print('SecureStorage delete error: $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kDebugMode) print('SecureStorage deleteAll error: $e');
    }
  }
}
