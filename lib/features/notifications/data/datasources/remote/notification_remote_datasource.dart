import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/features/notifications/data/models/notification_api_model.dart';
import 'package:sajilofix/features/notifications/domain/entities/notification_item.dart';

class NotificationRemoteDatasource {
  final ApiClient _apiClient;

  NotificationRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<NotificationPage> listNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
          if (isRead != null) 'isRead': isRead,
        },
      );
      final data = _asJsonMap(response.data);
      final payload = _asJsonMap(data['data']);
      final rawItems = payload['items'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (e) => NotificationApiModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ).toEntity(),
                )
                .toList()
          : const <NotificationItem>[];

      return NotificationPage(
        items: items,
        total: _toInt(payload['total']) ?? items.length,
        page: _toInt(payload['page']) ?? page,
        limit: _toInt(payload['limit']) ?? limit,
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationsUnreadCount,
      );
      final data = _asJsonMap(response.data);
      final payload = _asJsonMap(data['data']);
      return _toInt(payload['unreadCount']) ?? 0;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<NotificationItem> markRead(String id) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.notificationById}$id/read',
      );
      final data = _asJsonMap(response.data);
      final payload = _extractPayloadMap(data);
      if (payload == null) {
        throw ApiException.fromError('Missing notification payload');
      }
      return NotificationApiModel.fromJson(payload).toEntity();
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<int> markAllRead() async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.notificationsReadAll,
      );
      final data = _asJsonMap(response.data);
      final payload = _asJsonMap(data['data']);
      return _toInt(payload['modifiedCount']) ?? 0;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.notificationById}$id');
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

  Map<String, dynamic>? _extractPayloadMap(Map<String, dynamic> data) {
    final direct = data['data'];
    if (direct is Map) return Map<String, dynamic>.from(direct);
    return null;
  }

  Object? _tryDecodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  int? _toInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}
