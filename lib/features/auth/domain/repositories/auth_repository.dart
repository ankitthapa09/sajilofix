import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<void> signup({
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
  });

  Future<AuthUser> login({
    required String email,
    required String password,
    required int roleIndex,
  });

  Future<AuthUser?> getCurrentUser();

  Future<void> logout();
}
