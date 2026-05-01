import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthTokens> login({
    required String mobile,
    required String password,
  });
}
