import 'package:pscommunitymobileapp/features/auth/domain/entities/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {

  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthTokens> call({
    required String mobile,
    required String password,
  }) {
    return _repository.memberLogin(mobile: mobile, password: password);
  }
}
