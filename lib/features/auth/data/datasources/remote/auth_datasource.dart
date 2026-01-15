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
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: <String, dynamic>{'email': email.trim(), 'password': password},
      );

      final data = _asJsonMap(response.data);

      final token = (data['token'] ?? '').toString();
      final userJson = data['user'];
      if (userJson is! Map) {
        throw ApiException.fromError('Missing user in login response');
      }

      final user = AuthApiModel.fromJSON(Map<String, dynamic>.from(userJson));

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
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: user.toJSON(),
      );

      final data = _asJsonMap(response.data);
      final userJson = data['user'];
      if (userJson is! Map) {
        throw ApiException.fromError('Missing user in register response');
      }

      final registeredUser = AuthApiModel.fromJSON(
        Map<String, dynamic>.from(userJson),
      );

      return registeredUser;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
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

    throw ApiException.fromError(
      'Unexpected response type: ${data.runtimeType}',
    );
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
