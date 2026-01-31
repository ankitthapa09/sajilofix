import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/core/services/network/network_info.dart';
import 'package:sajilofix/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilofix/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';
import 'package:sajilofix/features/auth/data/models/local_user.dart';
import 'package:sajilofix/features/auth/data/repositories/auth_repository_impl.dart';

class _FakeNetworkInfo implements INetworkInfo {
  final bool connected;
  const _FakeNetworkInfo(this.connected);

  @override
  Future<bool> get isConnected async => connected;
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  LocalUser? loginResult;
  int loginCalls = 0;

  @override
  Future<LocalUser> login({
    required String email,
    required String password,
    required int roleIndex,
  }) async {
    loginCalls++;
    final result = loginResult;
    if (result == null) {
      throw const AuthLocalException('No user set in fake');
    }
    return result;
  }
}

class _UnusedRemote implements IAuthRemoteDataSource {
  @override
  Future<AuthApiModel?> getMe() => throw UnimplementedError();

  @override
  Future<AuthApiModel?> getUserById(String authId) =>
      throw UnimplementedError();

  @override
  Future<AuthApiModel?> login(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<AuthApiModel> register(AuthApiModel user) =>
      throw UnimplementedError();
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    await UserSessionService.clear();
  });

  test('offline login uses local datasource and sets session email', () async {
    final local = _FakeAuthLocalDataSource();
    local.loginResult = LocalUser(
      email: 'user@example.com',
      fullName: 'User',
      phone: '9812345678',
      roleIndex: 0,
      passwordHash: 'hash',
      createdAt: DateTime.utc(2025, 1, 1),
    );

    final repo = AuthRepositoryImpl(
      local,
      remote: _UnusedRemote(),
      networkInfo: const _FakeNetworkInfo(false),
    );

    final user = await repo.login(
      email: 'user@example.com',
      password: 'pw',
      roleIndex: 0,
    );

    expect(local.loginCalls, 1);
    expect(user.email, 'user@example.com');
    expect(UserSessionService.currentUserEmail, 'user@example.com');
  });
}
