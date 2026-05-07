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
        'ipAddress': '192.168.1.1',
      },
    );

    return _mapAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokens> memberLogin({
    required String mobile,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.memberLogin,
      data: {
        'mobileNo': mobile,
        'password': password,
        'ipAddress': '192.168.1.1',
      },
    );

    return _mapAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> memberUpdatePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.memberUpdatePassword,
      data: {
        'mobileNo': mobileNo,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final succeeded = data['succeeded'] as bool? ?? false;
    
    if (!succeeded) {
      final msg = data['message']?.toString() ?? 'Update password failed';
      throw ServerFailure(msg);
    }
  }

  AuthTokens _mapAuthResponse(Map<String, dynamic> data) {
    final succeeded = data['succeeded'] as bool? ?? false;
    
    if (!succeeded) {
      final msg = data['message']?.toString() ?? 'Authentication failed';
      throw ServerFailure(msg);
    }

    final authData = data['data'] as Map<String, dynamic>? ?? {};
    final accessToken = authData['accessToken']?.toString() ?? '';
    final refreshToken = authData['refreshToken']?.toString() ?? '';
    final isDefault = authData['isDefaultPassword'] as bool? ?? false;

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const ServerFailure('Response is missing authentication tokens');
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isDefaultPassword: isDefault,
      accessTokenExpiry: authData['accessTokenExpiry']?.toString(),
      memberId: authData['memberId'] as int?,
      samajId: authData['samajId'] as int?,
      firstName: authData['firstName']?.toString(),
      middleName: authData['middleName']?.toString(),
      lastName: authData['lastName']?.toString(),
      email: authData['email']?.toString(),
    );
  }
}
