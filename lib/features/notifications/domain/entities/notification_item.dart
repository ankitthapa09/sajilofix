class NotificationItem {
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

  const NotificationItem({
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

  NotificationItem copyWith({
    String? id,
    String? recipientUserId,
    String? recipientRole,
    String? type,
    String? title,
    String? message,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      recipientRole: recipientRole ?? this.recipientRole,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationPage {
  final List<NotificationItem> items;
  final int total;
  final int page;
  final int limit;

  const NotificationPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => page * limit < total;
}
