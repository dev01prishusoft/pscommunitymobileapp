import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/core/storage/secure_storage_service.dart';

import 'token_manager_test.mocks.dart';

@GenerateMocks([SecureStorageService])
void main() {
  late TokenManager tokenManager;
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockStorage = MockSecureStorageService();
    tokenManager = TokenManager(mockStorage);
  });

  String createJwt(Map<String, dynamic> payload) {
    final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')).replaceAll('=', '');
    final payloadStr = base64Url.encode(utf8.encode(json.encode(payload))).replaceAll('=', '');
    return '$header.$payloadStr.signature';
  }

  test('decodeJwtPayload decodes valid JWT and parses member properties', () async {
    final exp = (DateTime.now().toUtc().add(const Duration(days: 1)).millisecondsSinceEpoch / 1000).round();
    final jwt = createJwt({'exp': exp, 'memberId': 123, 'mobile': '9876543210', 'email': 'test@example.com'});
    
    when(mockStorage.read('access_token')).thenAnswer((_) async => jwt);
    when(mockStorage.read('refresh_token')).thenAnswer((_) async => null);
    when(mockStorage.read('is_default_pwd')).thenAnswer((_) async => null);
    when(mockStorage.read('user_mobile')).thenAnswer((_) async => null);
    
    await tokenManager.bootstrap();
    expect(tokenManager.memberId, 123);
    expect(tokenManager.userPhone, '9876543210');
    expect(tokenManager.userEmail, 'test@example.com');
    expect(tokenManager.isAccessTokenExpired, false);
    expect(tokenManager.isAccessTokenNearExpiry, false);
  });
  
  test('JWT expired if exp claim is in past', () async {
    final exp = (DateTime.now().toUtc().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch / 1000).round();
    final jwt = createJwt({'exp': exp});
    
    when(mockStorage.read('access_token')).thenAnswer((_) async => jwt);
    when(mockStorage.read('refresh_token')).thenAnswer((_) async => null);
    when(mockStorage.read('is_default_pwd')).thenAnswer((_) async => null);
    when(mockStorage.read('user_mobile')).thenAnswer((_) async => null);
    
    await tokenManager.bootstrap();
    expect(tokenManager.isAccessTokenExpired, true);
  });

  test('JWT near expiry if within 5 minutes', () async {
    final exp = (DateTime.now().toUtc().add(const Duration(minutes: 3)).millisecondsSinceEpoch / 1000).round();
    final jwt = createJwt({'exp': exp});
    
    when(mockStorage.read('access_token')).thenAnswer((_) async => jwt);
    when(mockStorage.read('refresh_token')).thenAnswer((_) async => null);
    when(mockStorage.read('is_default_pwd')).thenAnswer((_) async => null);
    when(mockStorage.read('user_mobile')).thenAnswer((_) async => null);
    
    await tokenManager.bootstrap();
    // It's not expired yet (has 30s threshold, 3 mins > 30s)
    expect(tokenManager.isAccessTokenExpired, false);
    // But it is near expiry (within 5 mins)
    expect(tokenManager.isAccessTokenNearExpiry, true);
  });

  test('Malformed JWT treated as expired', () async {
    when(mockStorage.read('access_token')).thenAnswer((_) async => 'not.a.jwt');
    when(mockStorage.read('refresh_token')).thenAnswer((_) async => null);
    when(mockStorage.read('is_default_pwd')).thenAnswer((_) async => null);
    when(mockStorage.read('user_mobile')).thenAnswer((_) async => null);
    
    await tokenManager.bootstrap();
    expect(tokenManager.isAccessTokenExpired, true);
  });

  test('Missing exp claim treated as expired', () async {
    final jwt = createJwt({'memberId': 123});
    
    when(mockStorage.read('access_token')).thenAnswer((_) async => jwt);
    when(mockStorage.read('refresh_token')).thenAnswer((_) async => null);
    when(mockStorage.read('is_default_pwd')).thenAnswer((_) async => null);
    when(mockStorage.read('user_mobile')).thenAnswer((_) async => null);
    
    await tokenManager.bootstrap();
    expect(tokenManager.isAccessTokenExpired, true);
  });
}
