import 'package:sajilofix/features/notifications/domain/entities/notification_item.dart';

class NotificationApiModel {
  final String id;
  final String recipientUserId;
  final String recipientRole;
  final String type;
  final String title;
  final String message;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const NotificationApiModel({
    required this.id,
    required this.recipientUserId,
    required this.recipientRole,
    required this.type,
    required this.title,
    required this.message,
    required this.entityType,
    this.entityId,
    this.metadata,
    required this.isRead,
    this.readAt,
    this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      recipientUserId: (json['recipientUserId'] ?? '').toString(),
      recipientRole: (json['recipientRole'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      entityType: (json['entityType'] ?? 'system').toString(),
      entityId: json['entityId']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      isRead: json['isRead'] == true,
      readAt: _tryParseDateTime(json['readAt']),
      createdAt: _tryParseDateTime(json['createdAt']),
    );
  }

  NotificationItem toEntity() {
    return NotificationItem(
      id: id,
      recipientUserId: recipientUserId,
      recipientRole: recipientRole,
      type: type,
      title: title,
      message: message,
      entityType: entityType,
      entityId: entityId,
      metadata: metadata,
      isRead: isRead,
      readAt: readAt,
      createdAt: createdAt,
    );
  }

  static DateTime? _tryParseDateTime(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    return null;
  }
}
