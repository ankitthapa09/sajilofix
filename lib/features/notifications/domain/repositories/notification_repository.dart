import 'package:sajilofix/features/notifications/domain/entities/notification_item.dart';

abstract interface class NotificationRepository {
  Future<NotificationPage> listNotifications({
    int page,
    int limit,
    bool? isRead,
  });

  Future<int> getUnreadCount();

  Future<NotificationItem> markRead(String id);

  Future<int> markAllRead();

  Future<void> deleteNotification(String id);
}
