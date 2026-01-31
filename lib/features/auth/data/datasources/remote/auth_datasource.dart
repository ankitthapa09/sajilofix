import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/core/services/storage/user_session_service.dart';
import 'package:sajilofix/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';

// create a provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  AuthRemoteDatasource({
    required ApiClient apiClient,
    FlutterSecureStorage? storage,
  }) : _apiClient = apiClient,
       _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> getMe() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMe);
      final data = _asJsonMap(response.data);

      final userMap = _extractUserMap(data);
      if (userMap == null) return null;

      return AuthApiModel.fromJSON(userMap);
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: <String, dynamic>{'email': email.trim(), 'password': password},
      );

      final data = _asJsonMap(response.data);

      final token = _readString(data, ['token', 'data.token', 'result.token']);

      final userMap = _extractUserMap(data);
      if (userMap == null) {
        throw ApiException.fromError(
          'Missing user in login response (keys: ${data.keys.toList()})',
        );
      }

      final user = AuthApiModel.fromJSON(userMap);

      // Save minimal session info (existing app behavior)
      await UserSessionService.setCurrentUserEmail(user.email);

      // Save token for auth interceptor
      if (token.trim().isNotEmpty) {
        await _storage.write(key: _tokenKey, value: token);
      }

      return user;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final payload = _sanitizeRegisterPayload(user.toJSON());
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: payload,
      );

      final data = _asJsonMap(response.data);

      final userMap = _extractUserMap(data);
      if (userMap != null) {
        return AuthApiModel.fromJSON(userMap);
      }

      // Some backends return only `{message}` or an id on register.
      // If the backend accepted the request (2xx) but omitted `user`, treat it as success
      // and return the submitted user (with id if present).
      final id = _readString(data, [
        '_id',
        'id',
        'userId',
        'data._id',
        'data.id',
      ]);
      return AuthApiModel(
        id: id.trim().isEmpty ? null : id,
        fullName: (payload['fullName'] ?? user.fullName).toString(),
        email: (payload['email'] ?? user.email).toString(),
        phone: payload['phone']?.toString() ?? user.phone,
        password: user.password,
        roleIndex: user.roleIndex,
        dob: payload['dob']?.toString() ?? user.dob,
        citizenshipNumber:
            payload['citizenshipNumber']?.toString() ?? user.citizenshipNumber,
        district: payload['district']?.toString() ?? user.district,
        municipality: payload['municipality']?.toString() ?? user.municipality,
        ward: payload['ward']?.toString() ?? user.ward,
        tole: payload['tole']?.toString() ?? user.tole,
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Map<String, dynamic> _sanitizeRegisterPayload(Map<String, dynamic> raw) {
    final payload = Map<String, dynamic>.from(raw);

    // Remove empty optional fields (common cause of validation failures).
    payload.removeWhere(
      (_, v) => v == null || (v is String && v.trim().isEmpty),
    );

    final phone = payload['phone'];
    if (phone is String) {
      payload['phone'] = _normalizePhone(phone);
      if ((payload['phone'] as String).trim().isEmpty) {
        payload.remove('phone');
      }
    }

    final dob = payload['dob'];
    if (dob is String) {
      payload['dob'] = _normalizeDob(dob);
    }

    final ward = payload['ward'];
    if (ward is String) {
      final normalizedWard = _normalizeWard(ward);
      if (normalizedWard.trim().isEmpty) {
        payload.remove('ward');
      } else {
        payload['ward'] = normalizedWard;
      }
    }

    return payload;
  }

  String _normalizePhone(String input) {
    var v = input.trim().replaceAll(' ', '');
    if (v.startsWith('+977')) v = v.substring(4);
    if (v.startsWith('977')) v = v.substring(3);
    if (v.startsWith('0') && v.length == 11) v = v.substring(1);
    return v;
  }

  String _normalizeDob(String input) {
    final v = input.trim();
    if (v.isEmpty) return v;

    // Convert dd/MM/yyyy -> yyyy-MM-dd
    final parts = v.split('/');
    if (parts.length == 3) {
      final dd = int.tryParse(parts[0]);
      final mm = int.tryParse(parts[1]);
      final yyyy = int.tryParse(parts[2]);
      if (dd != null && mm != null && yyyy != null) {
        return '${yyyy.toString().padLeft(4, '0')}-${mm.toString().padLeft(2, '0')}-${dd.toString().padLeft(2, '0')}';
      }
    }

    return v;
  }

  String _normalizeWard(String input) {
    final v = input.trim();
    if (v.isEmpty) return v;

    // Accept "Ward 2" -> "2"
    final match = RegExp(r'(\d+)').firstMatch(v);
    return match?.group(1) ?? v;
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

    throw ApiException.fromError(
      'Unexpected response type: ${data.runtimeType}',
    );
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> data) {
    final direct = data['user'];
    if (direct is Map) return Map<String, dynamic>.from(direct);

    final containerKeys = ['data', 'result', 'payload'];
    for (final key in containerKeys) {
      final container = data[key];
      if (container is Map) {
        // Some backends return the user object directly as `data`/`result`.
        // Example: { success, message, token, data: { ...user... } }
        // In that case there is no nested `user` key.

        final user = container['user'];
        if (user is Map) return Map<String, dynamic>.from(user);

        return Map<String, dynamic>.from(container);
      }
    }

    return null;
  }

  String _readString(Map<String, dynamic> data, List<String> paths) {
    for (final path in paths) {
      final value = _readPath(data, path);
      if (value == null) continue;
      final s = value.toString();
      if (s.trim().isNotEmpty) return s;
    }
    return '';
  }

  Object? _readPath(Map<String, dynamic> data, String path) {
    if (!path.contains('.')) return data[path];

    Object? current = data;
    for (final part in path.split('.')) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  Object? _tryDecodeJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return trimmed;
    }
  }
}
