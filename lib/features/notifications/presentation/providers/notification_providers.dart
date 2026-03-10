import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/core/services/network/network_info.dart';
import 'package:sajilofix/features/notifications/data/datasources/remote/notification_remote_datasource.dart';
import 'package:sajilofix/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:sajilofix/features/notifications/domain/entities/notification_item.dart';
import 'package:sajilofix/features/notifications/domain/repositories/notification_repository.dart';

final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
      return NotificationRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remote: ref.read(notificationRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  return ref.read(notificationRepositoryProvider).getUnreadCount();
});

enum NotificationFilter { all, unread }

final notificationsControllerProvider =
    StateNotifierProvider<
      NotificationsController,
      AsyncValue<NotificationPage>
    >(
      (ref) =>
          NotificationsController(ref.read(notificationRepositoryProvider)),
    );

class NotificationsController
    extends StateNotifier<AsyncValue<NotificationPage>> {
  final NotificationRepository _repository;
  NotificationFilter _filter = NotificationFilter.all;
  int _page = 1;
  int _limit = 20;
  bool _hasMore = true;
  bool _loadingMore = false;

  NotificationsController(this._repository)
    : super(const AsyncValue.loading()) {
    load();
  }

  NotificationFilter get filter => _filter;

  Future<void> load({NotificationFilter? filter}) async {
    if (filter != null && filter != _filter) {
      _filter = filter;
    }

    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.listNotifications(
        page: _page,
        limit: _limit,
        isRead: _filter == NotificationFilter.unread ? false : null,
      ),
    );

    final current = state.valueOrNull;
    if (current != null) {
      _page = current.page;
      _limit = current.limit;
      _hasMore = current.hasMore;
    }
  }

  Future<void> refresh() async {
    await load(filter: _filter);
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;

    final nextPage = _page + 1;
    try {
      final result = await _repository.listNotifications(
        page: nextPage,
        limit: _limit,
        isRead: _filter == NotificationFilter.unread ? false : null,
      );

      final current = state.valueOrNull;
      if (current == null) {
        state = AsyncValue.data(result);
        _page = result.page;
        _limit = result.limit;
        _hasMore = result.hasMore;
        return;
      }

      final merged = NotificationPage(
        items: [...current.items, ...result.items],
        total: result.total,
        page: result.page,
        limit: result.limit,
      );

      state = AsyncValue.data(merged);
      _page = merged.page;
      _limit = merged.limit;
      _hasMore = merged.hasMore;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> markRead(String id) async {
    final updated = await _repository.markRead(id);
    final current = state.valueOrNull;
    if (current == null) return;

    final items = current.items
        .map((item) => item.id == id ? updated : item)
        .toList();

    state = AsyncValue.data(
      NotificationPage(
        items: items,
        total: current.total,
        page: current.page,
        limit: current.limit,
      ),
    );
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    final current = state.valueOrNull;
    if (current == null) return;

    final items = current.items
        .map((item) => item.isRead ? item : item.copyWith(isRead: true))
        .toList();

    state = AsyncValue.data(
      NotificationPage(
        items: items,
        total: current.total,
        page: current.page,
        limit: current.limit,
      ),
    );
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    final current = state.valueOrNull;
    if (current == null) return;

    final items = current.items.where((item) => item.id != id).toList();
    final nextTotal = current.total > 0 ? current.total - 1 : 0;
    state = AsyncValue.data(
      NotificationPage(
        items: items,
        total: nextTotal,
        page: current.page,
        limit: current.limit,
      ),
    );
  }
}
