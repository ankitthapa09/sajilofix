import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/features/dashboard/admin/data/admin_users_remote_datasource.dart';
import 'package:sajilofix/features/dashboard/admin/domain/entities/admin_user_row.dart';

final adminUsersRemoteDatasourceProvider = Provider<AdminUsersRemoteDatasource>(
  (ref) => AdminUsersRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

class AdminUsersState {
  final List<AdminUserRow> users;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final String search;
  final String role;
  final String status;
  final String? error;

  const AdminUsersState({
    required this.users,
    required this.isLoading,
    required this.isLoadingMore,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.search,
    required this.role,
    required this.status,
    this.error,
  });

  factory AdminUsersState.initial() {
    return const AdminUsersState(
      users: [],
      isLoading: false,
      isLoadingMore: false,
      page: 1,
      limit: 20,
      total: 0,
      totalPages: 1,
      search: '',
      role: '',
      status: '',
      error: null,
    );
  }

  bool get hasMore => page < totalPages;

  AdminUsersState copyWith({
    List<AdminUserRow>? users,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    String? search,
    String? role,
    String? status,
    String? error,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
      role: role ?? this.role,
      status: status ?? this.status,
      error: error,
    );
  }
}

class AdminUsersController extends StateNotifier<AdminUsersState> {
  final AdminUsersRemoteDatasource _remote;

  AdminUsersController(this._remote) : super(AdminUsersState.initial());

  Future<void> load({String? search, String? role, String? status}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      search: search ?? state.search,
      role: role ?? state.role,
      status: status ?? state.status,
      page: 1,
    );

    try {
      final pageData = await _remote.listUsers(
        page: 1,
        limit: state.limit,
        search: state.search,
        role: state.role,
        status: state.status,
      );
      state = state.copyWith(
        users: pageData.users,
        isLoading: false,
        page: pageData.page,
        total: pageData.total,
        totalPages: pageData.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await load(search: state.search, role: state.role, status: state.status);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.page + 1;
      final pageData = await _remote.listUsers(
        page: nextPage,
        limit: state.limit,
        search: state.search,
        role: state.role,
        status: state.status,
      );
      state = state.copyWith(
        users: [...state.users, ...pageData.users],
        isLoadingMore: false,
        page: pageData.page,
        total: pageData.total,
        totalPages: pageData.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> createAuthority({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String wardNumber,
    required String municipality,
    required String department,
    required String status,
  }) async {
    await _remote.createAuthority(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      wardNumber: wardNumber,
      municipality: municipality,
      department: department,
      status: status,
    );
    await refresh();
  }

  Future<void> createCitizen({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String wardNumber,
    required String municipality,
    required String status,
    String? district,
    String? tole,
    String? dob,
    String? citizenshipNumber,
  }) async {
    await _remote.createCitizen(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      wardNumber: wardNumber,
      municipality: municipality,
      status: status,
      district: district,
      tole: tole,
      dob: dob,
      citizenshipNumber: citizenshipNumber,
    );
    await refresh();
  }

  Future<void> updateAuthority({
    required String id,
    String? fullName,
    String? email,
    String? password,
    String? phone,
    String? wardNumber,
    String? municipality,
    String? department,
    String? status,
  }) async {
    await _remote.updateAuthority(
      id: id,
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      wardNumber: wardNumber,
      municipality: municipality,
      department: department,
      status: status,
    );
    await refresh();
  }

  Future<void> updateCitizen({
    required String id,
    String? fullName,
    String? email,
    String? password,
    String? phone,
    String? wardNumber,
    String? municipality,
    String? status,
    String? district,
    String? tole,
    String? dob,
    String? citizenshipNumber,
  }) async {
    await _remote.updateCitizen(
      id: id,
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      wardNumber: wardNumber,
      municipality: municipality,
      status: status,
      district: district,
      tole: tole,
      dob: dob,
      citizenshipNumber: citizenshipNumber,
    );
    await refresh();
  }

  Future<void> deleteUser({required String id, required String role}) async {
    if (role == 'authority') {
      await _remote.deleteAuthority(id);
    } else if (role == 'citizen') {
      await _remote.deleteCitizen(id);
    }
    await refresh();
  }
}

final adminUsersControllerProvider =
    StateNotifierProvider<AdminUsersController, AdminUsersState>((ref) {
      return AdminUsersController(ref.read(adminUsersRemoteDatasourceProvider));
    });
