import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Result<AuthTokens>> login({required String mobile, required String password});

  Future<Result<AuthTokens>> memberLogin({
    required String mobile,
    required String password,
  });

  Future<Result<void>> memberUpdatePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
  });

  Future<Result<AuthTokens>> memberRefreshToken({required String refreshToken});

  Future<Result<void>> memberRevokeToken({required String refreshToken});
}
