import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    } catch (_) {}
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: 'ps_community_$key');
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: 'ps_community_$key');
    } catch (_) {}
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }

  Future<void> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<bool> getBool(String key) async {
    final value = await _storage.read(key: key);
    return value == 'true';
  }
}
