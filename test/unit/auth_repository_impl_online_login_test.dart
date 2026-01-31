import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/core/services/network/network_info.dart';
import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilofix/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';
import 'package:sajilofix/features/auth/data/repositories/auth_repository_impl.dart';

class _FakeNetworkInfo implements INetworkInfo {
  final bool connected;
  const _FakeNetworkInfo(this.connected);

  @override
  Future<bool> get isConnected async => connected;
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  int upsertCalls = 0;

  @override
  Future<void> upsertUser({
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
    String? profilePhoto,
    DateTime? createdAt,
  }) async {
    upsertCalls++;
  }
}

class _FakeRemote implements IAuthRemoteDataSource {
  AuthApiModel? loginResult;

  @override
  Future<AuthApiModel?> login(String email, String password) async =>
      loginResult;

  @override
  Future<AuthApiModel> register(AuthApiModel user) =>
      throw UnimplementedError();

  @override
  Future<AuthApiModel?> getMe() => throw UnimplementedError();

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

  test('online login throws ApiException when remote returns null', () async {
    final local = _FakeAuthLocalDataSource();
    final remote = _FakeRemote()..loginResult = null;

    final repo = AuthRepositoryImpl(
      local,
      remote: remote,
      networkInfo: const _FakeNetworkInfo(true),
    );

    await expectLater(
      () => repo.login(email: 'e', password: 'p', roleIndex: 0),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Invalid login response'),
        ),
      ),
    );

    expect(local.upsertCalls, 0);
  });

  test('online login throws ApiException when roleIndex mismatches', () async {
    final local = _FakeAuthLocalDataSource();
    final remote = _FakeRemote()
      ..loginResult = AuthApiModel(
        id: '1',
        fullName: 'User',
        email: 'user@example.com',
        phone: '9812345678',
        roleIndex: 2,
        createdAt: DateTime.utc(2025, 1, 1),
      );

    final repo = AuthRepositoryImpl(
      local,
      remote: remote,
      networkInfo: const _FakeNetworkInfo(true),
    );

    await expectLater(
      () => repo.login(email: 'e', password: 'p', roleIndex: 0),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Role does not match'),
        ),
      ),
    );

    expect(local.upsertCalls, 0);
  });
}
