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
    final response = await _apiClient.postParsed<AuthTokens>(
      ApiEndpoints.login,
      data: {
        'mobile': mobile,
        'password': password,
      },
      fromJsonT: (json) => _mapAuthResponseData(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<AuthTokens> memberLogin({
    required String mobile,
    required String password,
  }) async {
    final response = await _apiClient.postParsed<AuthTokens>(
      ApiEndpoints.memberLogin,
      data: {
        'mobileNo': mobile,
        'password': password,
      },
      fromJsonT: (json) => _mapAuthResponseData(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> memberUpdatePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.postParsed<void>(
      ApiEndpoints.memberUpdatePassword,
      data: {
        'mobileNo': mobileNo,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      // Since we just need it to succeed and the parser handles json['succeeded']
    );
  }

  AuthTokens _mapAuthResponseData(Map<String, dynamic> authData) {
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
