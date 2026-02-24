import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/features/dashboard/admin/domain/entities/admin_user_row.dart';

class AdminUsersPage {
  final List<AdminUserRow> users;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const AdminUsersPage({
    required this.users,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}

class AdminUsersRemoteDatasource {
  final ApiClient _apiClient;

  AdminUsersRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<AdminUsersPage> listUsers({
    required int page,
    required int limit,
    String? search,
    String? role,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.adminUsers,
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
          if ((search ?? '').trim().isNotEmpty) 'search': search?.trim(),
          if ((role ?? '').trim().isNotEmpty) 'role': role?.trim(),
          if ((status ?? '').trim().isNotEmpty) 'status': status?.trim(),
        },
      );

      final data = _asJsonMap(response.data);
      final rows = _extractList(data, [
        'data',
      ]).map((item) => AdminUserRow.fromJson(item)).toList();

      final meta = _asJsonMap(data['meta']);
      return AdminUsersPage(
        users: rows,
        page: _readInt(meta, 'page') ?? page,
        limit: _readInt(meta, 'limit') ?? limit,
        total: _readInt(meta, 'total') ?? rows.length,
        totalPages: _readInt(meta, 'totalPages') ?? 1,
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<AdminUserRow> createAuthority({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String wardNumber,
    required String municipality,
    required String department,
    required String status,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminAuthorities,
        data: <String, dynamic>{
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
          'wardNumber': wardNumber.trim(),
          'municipality': municipality.trim(),
          'department': department.trim(),
          'status': status,
        },
      );
      final data = _asJsonMap(response.data);
      final userMap = _asJsonMap(data['data']);
      return AdminUserRow.fromJson(userMap);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<AdminUserRow> createCitizen({
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
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminCitizens,
        data: <String, dynamic>{
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
          'wardNumber': wardNumber.trim(),
          'municipality': municipality.trim(),
          'status': status,
          if ((district ?? '').trim().isNotEmpty) 'district': district?.trim(),
          if ((tole ?? '').trim().isNotEmpty) 'tole': tole?.trim(),
          if ((dob ?? '').trim().isNotEmpty) 'dob': dob?.trim(),
          if ((citizenshipNumber ?? '').trim().isNotEmpty)
            'citizenshipNumber': citizenshipNumber?.trim(),
        },
      );
      final data = _asJsonMap(response.data);
      final userMap = _asJsonMap(data['data']);
      return AdminUserRow.fromJson(userMap);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<AdminUserRow> updateAuthority({
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
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.adminAuthorityById}$id',
        data: _stripNulls(<String, dynamic>{
          'fullName': fullName?.trim(),
          'email': email?.trim(),
          'password': (password ?? '').trim().isEmpty ? null : password,
          'phone': phone?.trim(),
          'wardNumber': wardNumber?.trim(),
          'municipality': municipality?.trim(),
          'department': department?.trim(),
          'status': status?.trim(),
        }),
      );
      final data = _asJsonMap(response.data);
      final userMap = _asJsonMap(data['data']);
      return AdminUserRow.fromJson(userMap);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<AdminUserRow> updateCitizen({
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
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.adminCitizenById}$id',
        data: _stripNulls(<String, dynamic>{
          'fullName': fullName?.trim(),
          'email': email?.trim(),
          'password': (password ?? '').trim().isEmpty ? null : password,
          'phone': phone?.trim(),
          'wardNumber': wardNumber?.trim(),
          'municipality': municipality?.trim(),
          'status': status?.trim(),
          'district': district?.trim(),
          'tole': tole?.trim(),
          'dob': dob?.trim(),
          'citizenshipNumber': citizenshipNumber?.trim(),
        }),
      );
      final data = _asJsonMap(response.data);
      final userMap = _asJsonMap(data['data']);
      return AdminUserRow.fromJson(userMap);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<void> deleteAuthority(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.adminAuthorityById}$id');
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<void> deleteCitizen(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.adminCitizenById}$id');
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Map<String, dynamic> _stripNulls(Map<String, dynamic> input) {
    final data = Map<String, dynamic>.from(input);
    data.removeWhere((_, value) => value == null);
    return data;
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (status != null) {
      final parsed = data is String ? _tryDecodeJson(data) : data;
      return ApiException.fromResponse(statusCode: status, data: parsed);
    }
    return ApiException.fromError(e);
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = _tryDecodeJson(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  int? _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  dynamic _tryDecodeJson(String value) {
    try {
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }
}
