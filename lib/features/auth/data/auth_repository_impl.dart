import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthTokens> login({
    required String mobile,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'mobile': mobile,
        'password': password,
        'ipAddress': '',
      },
    );

    final data = response.data;
    final succeeded = data['succeeded'] as bool? ?? false;
    
    if (!succeeded) {
      final msg = data['message']?.toString() ?? 'Login failed';
      throw ServerFailure(msg);
    }

    final authData = data['data'] as Map<String, dynamic>? ?? {};
    final accessToken = authData['accessToken']?.toString() ?? '';
    final refreshToken = authData['refreshToken']?.toString() ?? '';

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const ServerFailure('Login response is missing authentication tokens');
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
