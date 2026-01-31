import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilofix/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';
import 'package:sajilofix/features/auth/data/models/local_user.dart';
import 'package:sajilofix/features/auth/data/repositories/auth_repository_impl.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  LocalUser? userByEmail;
  int getUserCalls = 0;

  @override
  Future<LocalUser?> getUserByEmail(String email) async {
    getUserCalls++;
    return userByEmail;
  }
}

class _ThrowingRemote implements IAuthRemoteDataSource {
  @override
  Future<AuthApiModel?> getMe() async {
    throw ApiException.fromError('network error');
  }

  @override
  Future<AuthApiModel?> login(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<AuthApiModel> register(AuthApiModel user) =>
      throw UnimplementedError();

  @override
  Future<AuthApiModel?> getUserById(String authId) =>
      throw UnimplementedError();
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    await UserSessionService.clear();
  });

  test('returns null when there is no current user email', () async {
    final repo = AuthRepositoryImpl(_FakeAuthLocalDataSource());
    final user = await repo.getCurrentUser();
    expect(user, isNull);
  });

  test('falls back to local when remote getMe throws', () async {
    await UserSessionService.setCurrentUserEmail('user@example.com');

    final local = _FakeAuthLocalDataSource();
    local.userByEmail = LocalUser(
      email: 'user@example.com',
      fullName: 'User',
      phone: '9812345678',
      roleIndex: 0,
      passwordHash: 'hash',
      createdAt: DateTime.utc(2025, 1, 1),
    );

    final repo = AuthRepositoryImpl(local, remote: _ThrowingRemote());

    final user = await repo.getCurrentUser();
    expect(local.getUserCalls, 1);
    expect(user?.email, 'user@example.com');
  });
}
