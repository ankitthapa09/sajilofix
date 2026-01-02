import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  const LoginUseCase(this._repo);

  Future<AuthUser> call({
    required String email,
    required String password,
    required int roleIndex,
  }) {
    return _repo.login(email: email, password: password, roleIndex: roleIndex);
  }
}
