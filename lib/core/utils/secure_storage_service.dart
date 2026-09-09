import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService()
    : _storage = FlutterSecureStorage(
        aOptions: AndroidOptions(resetOnError: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
          synchronizable: false,
        ),
      );

  final FlutterSecureStorage _storage;

  void _reportError(Object error, StackTrace stack, {required String reason}) {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: false,
      );
    } catch (_) {}
  }

  Future<void> write(String key, String? value) async {
    try {
      await _storage.write(key: 'ps_community_$key', value: value);
    } catch (e, stack) {
      _reportError(
        e,
        stack,
        reason: 'SecureStorage.write failed for key: $key',
      );
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: 'ps_community_$key');
    } catch (e, stack) {
      _reportError(e, stack, reason: 'SecureStorage.read failed for key: $key');
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: 'ps_community_$key');
    } catch (e, stack) {
      _reportError(
        e,
        stack,
        reason: 'SecureStorage.delete failed for key: $key',
      );
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, stack) {
      _reportError(e, stack, reason: 'SecureStorage.deleteAll failed');
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e, stack) {
      _reportError(
        e,
        stack,
        reason: 'SecureStorage.setBool failed for key: $key',
      );
    }
  }

  Future<bool> getBool(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value == 'true';
    } catch (e, stack) {
      _reportError(
        e,
        stack,
        reason: 'SecureStorage.getBool failed for key: $key',
      );
      return false;
    }
  }
}
