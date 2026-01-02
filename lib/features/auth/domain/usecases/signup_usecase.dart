import 'package:sajilofix/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository _repo;
  const SignupUseCase(this._repo);

  Future<void> call({
    required String fullName,
    required String email,
    required String phone,
    required int roleIndex,
    required String password,
    String? dob,
    String? citizenshipNumber,
    String? district,
    String? municipality,
    String? ward,
    String? tole,
  }) {
    return _repo.signup(
      fullName: fullName,
      email: email,
      phone: phone,
      roleIndex: roleIndex,
      password: password,
      dob: dob,
      citizenshipNumber: citizenshipNumber,
      district: district,
      municipality: municipality,
      ward: ward,
      tole: tole,
    );
  }
}
