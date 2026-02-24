import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/data/citizen_profile_remote_datasource.dart';

class CitizenProfileState {
  final bool isSyncing;
  final bool isUploading;
  final String? status;
  final String? error;

  const CitizenProfileState({
    required this.isSyncing,
    required this.isUploading,
    this.status,
    this.error,
  });

  factory CitizenProfileState.initial() {
    return const CitizenProfileState(
      isSyncing: false,
      isUploading: false,
      status: null,
      error: null,
    );
  }

  CitizenProfileState copyWith({
    bool? isSyncing,
    bool? isUploading,
    String? status,
    String? error,
  }) {
    return CitizenProfileState(
      isSyncing: isSyncing ?? this.isSyncing,
      isUploading: isUploading ?? this.isUploading,
      status: status ?? this.status,
      error: error,
    );
  }
}

final citizenProfileRemoteDatasourceProvider =
    Provider<CitizenProfileRemoteDatasource>((ref) {
      return CitizenProfileRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

final citizenProfileControllerProvider =
    StateNotifierProvider<CitizenProfileController, CitizenProfileState>((ref) {
      return CitizenProfileController(
        ref: ref,
        remote: ref.read(citizenProfileRemoteDatasourceProvider),
        local: ref.read(authLocalDataSourceProvider),
      );
    });

class CitizenProfileController extends StateNotifier<CitizenProfileState> {
  final Ref _ref;
  final CitizenProfileRemoteDatasource _remote;
  final AuthLocalDataSource _local;

  CitizenProfileController({
    required Ref ref,
    required CitizenProfileRemoteDatasource remote,
    required AuthLocalDataSource local,
  }) : _ref = ref,
       _remote = remote,
       _local = local,
       super(CitizenProfileState.initial());

  Future<void> syncCurrentUser() async {
    state = state.copyWith(isSyncing: true, error: null);
    try {
      final payload = await _remote.fetchMe();
      if (payload == null) {
        state = state.copyWith(isSyncing: false);
        return;
      }
      final remoteUser = payload.user;
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
      _ref.invalidate(currentUserProvider);
      state = state.copyWith(isSyncing: false, status: payload.status);
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  Future<void> uploadProfilePhoto({required FormData formData}) async {
    state = state.copyWith(isUploading: true, error: null);
    try {
      await _remote.uploadProfilePhoto(formData: formData);
      await syncCurrentUser();
      state = state.copyWith(isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
      rethrow;
    }
  }
}
