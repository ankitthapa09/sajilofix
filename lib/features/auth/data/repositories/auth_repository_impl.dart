import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/core/services/network/network_info.dart';
import 'package:sajilofix/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sajilofix/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilofix/features/auth/data/mappers/local_user_mapper.dart';
import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';
import 'package:sajilofix/features/auth/domain/repositories/auth_repository.dart';
import 'package:sajilofix/core/api/api_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;
  final IAuthRemoteDataSource? _remote;
  final INetworkInfo? _networkInfo;

  const AuthRepositoryImpl(
    this._local, {
    IAuthRemoteDataSource? remote,
    INetworkInfo? networkInfo,
  }) : _remote = remote,
       _networkInfo = networkInfo;

  Future<bool> _isOnline() async {
    final networkInfo = _networkInfo;
    if (networkInfo == null) return false;

    try {
      return await networkInfo.isConnected;
    } catch (_) {
      return false;
    }
  }

  Future<void> _cacheRemoteUserToLocal({
    required AuthApiModel remoteUser,
    required String password,
  }) async {
    await _local.upsertUser(
      fullName: remoteUser.fullName,
      email: remoteUser.email,
      phone: (remoteUser.phone ?? '').trim(),
      roleIndex: remoteUser.roleIndex,
      password: password,
      dob: remoteUser.dob,
      citizenshipNumber: remoteUser.citizenshipNumber,
      district: remoteUser.district,
      municipality: remoteUser.municipality,
      ward: remoteUser.ward,
      tole: remoteUser.tole,
      profilePhoto: remoteUser.profilePhoto,
      createdAt: remoteUser.createdAt,
    );
  }

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
    return _signup(
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

  Future<void> _signup({
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
    final remote = _remote;
    final online = await _isOnline();

    if (online && remote != null) {
      final apiUser = AuthApiModel(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password,
        roleIndex: roleIndex,
        dob: dob,
        citizenshipNumber: citizenshipNumber,
        district: district,
        municipality: municipality,
        ward: ward,
        tole: tole,
      );

      final registered = await remote.register(apiUser);

      // Cache for offline use (best-effort)
      await _cacheRemoteUserToLocal(remoteUser: registered, password: password);
      return;
    }

    await _local.signup(
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
    final remote = _remote;
    final online = await _isOnline();

    if (online && remote != null) {
      final remoteUser = await remote.login(email, password);
      if (remoteUser == null) {
        throw ApiException.fromError('Invalid login response');
      }

      if (remoteUser.roleIndex != roleIndex) {
        throw ApiException.fromError('Role does not match this account');
      }

      await _cacheRemoteUserToLocal(remoteUser: remoteUser, password: password);
      await UserSessionService.setCurrentUserEmail(remoteUser.email);

      return remoteUser.toEntity();
    }

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

    final remote = _remote;
    if (remote != null) {
      try {
        final remoteUser = await remote.getMe();
        if (remoteUser != null) {
          await _local.upsertUserPreservePasswordHash(
            fullName: remoteUser.fullName,
            email: remoteUser.email,
            phone: (remoteUser.phone ?? '').trim(),
            roleIndex: remoteUser.roleIndex,
            dob: remoteUser.dob,
            citizenshipNumber: remoteUser.citizenshipNumber,
            district: remoteUser.district,
            municipality: remoteUser.municipality,
            ward: remoteUser.ward,
            tole: remoteUser.tole,
            profilePhoto: remoteUser.profilePhoto,
            createdAt: remoteUser.createdAt,
          );
          await UserSessionService.setCurrentUserEmail(remoteUser.email);
          return remoteUser.toEntity();
        }
      } on ApiException {
        // fall back to local
      } catch (_) {
        // fall back to local
      }
    }

    final user = await _local.getUserByEmail(email!);
    return user?.toEntity();
  }

  @override
  Future<void> logout() => UserSessionService.clear();
}
