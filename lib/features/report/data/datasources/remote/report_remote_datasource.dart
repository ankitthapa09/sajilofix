import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/features/report/data/models/report_api_model.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';

class ReportRemoteDatasource {
  final ApiClient _apiClient;

  ReportRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<IssueReport> createIssueReport(CreateIssueReportInput input) async {
    try {
      final formData = await _buildCreateFormData(input);
      final response = await _apiClient.uploadFile(
        ApiEndpoints.issues,
        formData: formData,
        method: 'POST',
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = _asJsonMap(response.data);
      final payload = _extractPayloadMap(data);
      if (payload == null) {
        throw ApiException.fromError('Missing issue payload in response');
      }

      return IssueReportApiModel.fromJson(payload).toEntity();
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<List<IssueReport>> listIssues() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.issues);
      final data = _asJsonMap(response.data);
      final payload = data['data'];
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map(
              (e) => IssueReportApiModel.fromJson(
                Map<String, dynamic>.from(e),
              ).toEntity(),
            )
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<String> updateIssueStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.issueById}$id/status',
        data: <String, dynamic>{'status': status},
      );
      final data = _asJsonMap(response.data);
      final payload = data['data'];
      if (payload is Map) {
        final parsed = Map<String, dynamic>.from(payload);
        return (parsed['status'] ?? status).toString();
      }
      return status;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<void> deleteIssue(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.issueById}$id');
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<FormData> _buildCreateFormData(CreateIssueReportInput input) async {
    final locationJson = jsonEncode(<String, dynamic>{
      'address': input.location.address,
      'district': input.location.district,
      'municipality': input.location.municipality,
      'ward': input.location.ward,
      'landmark': input.location.landmark,
      'latitude': input.location.latitude,
      'longitude': input.location.longitude,
    });

    final files = <MultipartFile>[];
    for (final photo in input.photos) {
      files.add(await _toMultipartFile(photo));
    }

    return FormData.fromMap({
      'category': input.category,
      'title': input.title,
      'description': input.description,
      'urgency': input.urgency,
      'location': locationJson,
      if (files.isNotEmpty) 'photos': files,
    });
  }

  Future<MultipartFile> _toMultipartFile(XFile photo) async {
    if (kIsWeb) {
      final bytes = await photo.readAsBytes();
      return MultipartFile.fromBytes(bytes, filename: 'issue-photo.jpg');
    }
    return MultipartFile.fromFile(photo.path, filename: _fileName(photo.path));
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isNotEmpty ? parts.last : 'issue-photo.jpg';
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

  Map<String, dynamic>? _extractPayloadMap(Map<String, dynamic> data) {
    final direct = data['data'];
    if (direct is Map) return Map<String, dynamic>.from(direct);

    final user = data['issue'];
    if (user is Map) return Map<String, dynamic>.from(user);

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
