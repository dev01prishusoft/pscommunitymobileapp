import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

class TokenManager {
  final SecureStorageService _storage;
  
  final RxnString accessToken = RxnString();
  final RxnString refreshToken = RxnString();

  TokenManager(this._storage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> bootstrap() async {
    accessToken.value = await _storage.read(_accessKey);
    refreshToken.value = await _storage.read(_refreshKey);
  }

  Future<void> saveTokens(String access, String refresh) async {
    accessToken.value = access;
    refreshToken.value = refresh;
    await _storage.write(_accessKey, access);
    await _storage.write(_refreshKey, refresh);
  }

  Future<void> clearTokens() async {
    accessToken.value = null;
    refreshToken.value = null;
    await _storage.delete(_accessKey);
    await _storage.delete(_refreshKey);
  }

  bool get hasToken => accessToken.value != null;
}
