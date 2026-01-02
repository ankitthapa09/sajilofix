import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sajilofix/features/auth/data/mappers/local_user_mapper.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl(this._local);

  @override
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
  }) {
    return _local.signup(
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

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
    required int roleIndex,
  }) async {
    final user = await _local.login(
      email: email,
      password: password,
      roleIndex: roleIndex,
    );

    await UserSessionService.setCurrentUserEmail(user.email);
    return user.toEntity();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final email = UserSessionService.currentUserEmail;
    if ((email ?? '').trim().isEmpty) return null;

    final user = await _local.getUserByEmail(email!);
    return user?.toEntity();
  }

  @override
  Future<void> logout() => UserSessionService.clear();
}
