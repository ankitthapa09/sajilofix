import 'package:flutter_test/flutter_test.dart';

import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/domain/repositories/auth_repository.dart';
import 'package:sajilofix/features/auth/domain/usecases/login_usecase.dart';
import 'package:sajilofix/features/auth/domain/usecases/signup_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastEmail;
  String? lastPassword;
  int? lastRoleIndex;

  String? lastSignupFullName;
  String? lastSignupEmail;
  String? lastSignupPhone;
  int? lastSignupRoleIndex;
  String? lastSignupPassword;
  String? lastSignupDob;
  String? lastSignupCitizenshipNumber;
  String? lastSignupDistrict;
  String? lastSignupMunicipality;
  String? lastSignupWard;
  String? lastSignupTole;

  AuthUser? loginResult;
  Object? loginError;
  Object? signupError;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
    required int roleIndex,
  }) async {
    if (loginError != null) throw loginError!;
    lastEmail = email;
    lastPassword = password;
    lastRoleIndex = roleIndex;

    return loginResult!;
  }

  @override
  Future<AuthUser?> getCurrentUser() => throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

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
  }) async {
    if (signupError != null) throw signupError!;
    lastSignupFullName = fullName;
    lastSignupEmail = email;
    lastSignupPhone = phone;
    lastSignupRoleIndex = roleIndex;
    lastSignupPassword = password;
    lastSignupDob = dob;
    lastSignupCitizenshipNumber = citizenshipNumber;
    lastSignupDistrict = district;
    lastSignupMunicipality = municipality;
    lastSignupWard = ward;
    lastSignupTole = tole;
  }
}

void main() {
  test('LoginUseCase forwards params and returns repository user', () async {
    final repo = _FakeAuthRepository();
    repo.loginResult = AuthUser(
      email: 'citizen@example.com',
      fullName: 'Citizen One',
      phone: '9800000000',
      roleIndex: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final useCase = LoginUseCase(repo);

    final result = await useCase(
      email: 'citizen@example.com',
      password: 'safePass123',
      roleIndex: 0,
    );

    expect(repo.lastEmail, 'citizen@example.com');
    expect(repo.lastPassword, 'safePass123');
    expect(repo.lastRoleIndex, 0);
    expect(result.email, 'citizen@example.com');
    expect(result.fullName, 'Citizen One');
    expect(result.phone, '9800000000');
    expect(result.roleIndex, 0);
  });

  test('LoginUseCase returns same instance provided by repository', () async {
    final repo = _FakeAuthRepository();
    final expected = AuthUser(
      email: 'same@example.com',
      fullName: 'Same User',
      phone: '9800000001',
      roleIndex: 1,
      createdAt: DateTime.utc(2026, 1, 2),
    );
    repo.loginResult = expected;

    final useCase = LoginUseCase(repo);
    final result = await useCase(
      email: 'same@example.com',
      password: 'Secret@123',
      roleIndex: 1,
    );

    expect(identical(result, expected), isTrue);
  });

  test('LoginUseCase propagates repository exception', () async {
    final repo = _FakeAuthRepository()..loginError = StateError('login-failed');
    final useCase = LoginUseCase(repo);

    await expectLater(
      () => useCase(email: 'x@y.com', password: 'p', roleIndex: 0),
      throwsA(isA<StateError>()),
    );
  });

  test('SignupUseCase forwards all params to repository', () async {
    final repo = _FakeAuthRepository();
    final useCase = SignupUseCase(repo);

    await useCase(
      fullName: 'Ankit User',
      email: 'ankit@example.com',
      phone: '9811111111',
      roleIndex: 0,
      password: 'StrongPass@123',
      dob: '2000-01-01',
      citizenshipNumber: 'ABC123456',
      district: 'Kathmandu',
      municipality: 'Kathmandu Metro',
      ward: '10',
      tole: 'New Road',
    );

    expect(repo.lastSignupFullName, 'Ankit User');
    expect(repo.lastSignupEmail, 'ankit@example.com');
    expect(repo.lastSignupPhone, '9811111111');
    expect(repo.lastSignupRoleIndex, 0);
    expect(repo.lastSignupPassword, 'StrongPass@123');
    expect(repo.lastSignupDob, '2000-01-01');
    expect(repo.lastSignupCitizenshipNumber, 'ABC123456');
    expect(repo.lastSignupDistrict, 'Kathmandu');
    expect(repo.lastSignupMunicipality, 'Kathmandu Metro');
    expect(repo.lastSignupWard, '10');
    expect(repo.lastSignupTole, 'New Road');
  });

  test('SignupUseCase forwards required fields correctly', () async {
    final repo = _FakeAuthRepository();
    final useCase = SignupUseCase(repo);

    await useCase(
      fullName: 'Required User',
      email: 'required@example.com',
      phone: '9822222222',
      roleIndex: 1,
      password: 'ReqPass@123',
    );

    expect(repo.lastSignupFullName, 'Required User');
    expect(repo.lastSignupEmail, 'required@example.com');
    expect(repo.lastSignupPhone, '9822222222');
    expect(repo.lastSignupRoleIndex, 1);
    expect(repo.lastSignupPassword, 'ReqPass@123');
  });

  test('SignupUseCase keeps optional fields null when omitted', () async {
    final repo = _FakeAuthRepository();
    final useCase = SignupUseCase(repo);

    await useCase(
      fullName: 'Null Optional',
      email: 'nullopt@example.com',
      phone: '9833333333',
      roleIndex: 2,
      password: 'NullOpt@123',
    );

    expect(repo.lastSignupDob, isNull);
    expect(repo.lastSignupCitizenshipNumber, isNull);
    expect(repo.lastSignupDistrict, isNull);
    expect(repo.lastSignupMunicipality, isNull);
    expect(repo.lastSignupWard, isNull);
    expect(repo.lastSignupTole, isNull);
  });

  test('SignupUseCase propagates repository exception', () async {
    final repo = _FakeAuthRepository()
      ..signupError = StateError('signup-failed');
    final useCase = SignupUseCase(repo);

    await expectLater(
      () => useCase(
        fullName: 'Err User',
        email: 'err@example.com',
        phone: '9844444444',
        roleIndex: 0,
        password: 'Err@123',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('SignupUseCase forwards role index for authority signup', () async {
    final repo = _FakeAuthRepository();
    final useCase = SignupUseCase(repo);

    await useCase(
      fullName: 'Authority User',
      email: 'authority@example.com',
      phone: '9855555555',
      roleIndex: 1,
      password: 'Authority@123',
    );

    expect(repo.lastSignupRoleIndex, 1);
  });
}
