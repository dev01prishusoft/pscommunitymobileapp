import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';

class SecureStorageService {
  SecureStorageService()
    : _storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          resetOnError: true,
          
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
          synchronizable: false,
        ),
      );
  final FlutterSecureStorage _storage;

  Future<void> write(String key, String? value) async {
    try {
      await _storage.write(key: 'ps_community_$key', value: value);
    } catch (e, stack) {
      AppLogger.e('SecureStorage write error', e, stack);
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: 'ps_community_$key');
    } catch (e, stack) {
      AppLogger.e('SecureStorage read error', e, stack);
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: 'ps_community_$key');
    } catch (e, stack) {
      AppLogger.e('SecureStorage delete error', e, stack);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, stack) {
      AppLogger.e('SecureStorage deleteAll error', e, stack);
    }
  }
}
