import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthTokens> call({
    required String mobile,
    required String password,
  }) {
    return _repository.login(mobile: mobile, password: password);
  }
}
