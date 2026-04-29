import 'package:pscommunitymobileapp/core/constants/api_constants.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.loginPath,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'ipAddress': 'mobile-app',
      },
    );

    final succeeded = response['succeeded'] as bool? ?? false;
    if (!succeeded) {
      throw Exception(response['message']?.toString() ?? 'Login failed');
    }

    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final accessToken = data['accessToken']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? '';

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw Exception('Login response is missing authentication tokens');
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
