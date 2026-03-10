import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/core/services/network/network_info.dart';
import 'package:sajilofix/features/notifications/data/datasources/remote/notification_remote_datasource.dart';
import 'package:sajilofix/features/notifications/domain/entities/notification_item.dart';
import 'package:sajilofix/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remote;
  final INetworkInfo _networkInfo;

  const NotificationRepositoryImpl({
    required NotificationRemoteDatasource remote,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _networkInfo = networkInfo;

  @override
  Future<NotificationPage> listNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
  }) async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.listNotifications(page: page, limit: limit, isRead: isRead);
  }

  @override
  Future<int> getUnreadCount() async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.getUnreadCount();
  }

  @override
  Future<NotificationItem> markRead(String id) async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.markRead(id);
  }

  @override
  Future<int> markAllRead() async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.markAllRead();
  }

  @override
  Future<void> deleteNotification(String id) async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    await _remote.deleteNotification(id);
  }

  Future<bool> _safeOnlineCheck() async {
    try {
      return await _networkInfo.isConnected;
    } catch (_) {
      return false;
    }
  }
}
