import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';

class CitizenProfilePayload {
  final AuthApiModel user;
  final String? status;

  const CitizenProfilePayload({required this.user, this.status});
}

class CitizenProfileRemoteDatasource {
  final ApiClient _apiClient;

  CitizenProfileRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<CitizenProfilePayload?> fetchMe() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMe);
      final data = _asJsonMap(response.data);
      final userMap = _extractUserMap(data);
      if (userMap == null) return null;
      final status = userMap['status']?.toString();
      return CitizenProfilePayload(
        user: AuthApiModel.fromJSON(userMap),
        status: status,
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<void> uploadProfilePhoto({required FormData formData}) async {
    try {
      await _apiClient.uploadFile(
        ApiEndpoints.uploadProfilePhoto,
        formData: formData,
        method: 'PUT',
        options: Options(contentType: 'multipart/form-data'),
      );
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
        final user = container['user'];
        if (user is Map) return Map<String, dynamic>.from(user);
        return Map<String, dynamic>.from(container);
      }
    }

    return null;
  }

  Object? _tryDecodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }
}
