import 'package:pscommunitymobileapp/core/models/auth_tokens.dart';
import 'package:pscommunitymobileapp/features/auth/repositories/auth_repository.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthTokens>> call({required String mobile, required String password}) {
    return _repository.memberLogin(mobile: mobile, password: password);
  }
}
