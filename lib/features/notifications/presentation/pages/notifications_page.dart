import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/notifications/domain/entities/notification_item.dart';
import 'package:sajilofix/features/notifications/presentation/providers/notification_providers.dart';
import 'package:sajilofix/features/report/presentation/pages/report_view_page.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  NotificationFilter _filter = NotificationFilter.all;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      ref.read(notificationsControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _setFilter(NotificationFilter next) async {
    if (next == _filter) return;
    setState(() => _filter = next);
    await ref.read(notificationsControllerProvider.notifier).load(filter: next);
  }

  Future<void> _markAllRead() async {
    await ref.read(notificationsControllerProvider.notifier).markAllRead();
    ref.invalidate(unreadCountProvider);
  }

  Future<void> _onNotificationTap(NotificationItem item) async {
    final controller = ref.read(notificationsControllerProvider.notifier);
    if (!item.isRead) {
      await controller.markRead(item.id);
      ref.invalidate(unreadCountProvider);
    }

    final entityId = (item.entityId ?? '').trim();
    if (item.entityType != 'issue' || entityId.isEmpty) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final allowUpdate =
        currentUser?.roleIndex == 1 || currentUser?.roleIndex == 2;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final report = await ref
          .read(reportRepositoryProvider)
          .getIssueById(entityId);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ReportViewPage(report: report, allowStatusUpdate: allowUpdate),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showMySnackBar(context: context, message: e.toString());
    }
  }

  Future<void> _deleteNotification(NotificationItem item) async {
    await ref
        .read(notificationsControllerProvider.notifier)
        .deleteNotification(item.id);
    ref.invalidate(unreadCountProvider);
  }

  Future<bool> _confirmDelete(NotificationItem item) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete notification'),
              content: const Text(
                'This notification will be removed from your list.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final notificationsAsync = ref.watch(notificationsControllerProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final roleIndex = currentUser?.roleIndex ?? 0;
    final myReportsAsync = ref.watch(myReportsProvider);
    final myReportIds =
        myReportsAsync.valueOrNull?.map((report) => report.id).toSet() ??
        const <String>{};

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: onSurface),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    active: _filter == NotificationFilter.all,
                    onTap: () => _setFilter(NotificationFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Unread',
                    active: _filter == NotificationFilter.unread,
                    tone: const Color(0xFFEF4444),
                    onTap: () => _setFilter(NotificationFilter.unread),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => ref
                              .read(notificationsControllerProvider.notifier)
                              .refresh(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (page) {
                  final items = _filterForCurrentUser(
                    page.items,
                    roleIndex: roleIndex,
                    myReportIds: myReportIds,
                  );
                  if (items.isEmpty) {
                    return const Center(child: Text('No notifications yet.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(notificationsControllerProvider.notifier)
                        .refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: items.length + (page.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = items[index];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(item),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: const Color(0xFFEF4444),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => _deleteNotification(item),
                          child: _NotificationTile(
                            item: item,
                            isDark: isDark,
                            onTap: () => _onNotificationTap(item),
                            onDelete: () => _deleteNotification(item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<NotificationItem> _filterForCurrentUser(
    List<NotificationItem> items, {
    required int roleIndex,
    required Set<String> myReportIds,
  }) {
    if (items.isEmpty) return items;

    final role = switch (roleIndex) {
      1 => 'admin',
      2 => 'authority',
      _ => 'citizen',
    };

    final roleFiltered = items.where((item) => item.recipientRole == role);
    if (roleIndex != 0) return roleFiltered.toList();

    return roleFiltered.where((item) {
      if (item.entityType != 'issue') return true;
      final entityId = (item.entityId ?? '').trim();
      if (entityId.isEmpty) return false;
      return myReportIds.contains(entityId);
    }).toList();
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final timeLabel = _formatTime(item.createdAt);
    final accent = _typeColor(item.type);
    final isUnread = !item.isRead;
    final tileColor = isUnread
        ? (isDark ? const Color(0xFF213055) : const Color(0xFFE8F1FF))
        : (isDark ? const Color(0xFF0F1424) : const Color(0xFFFDFDFE));
    final borderColor = isUnread
        ? accent.withValues(alpha: isDark ? 0.65 : 0.45)
        : (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isUnread ? 1.6 : 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 40,
              margin: const EdgeInsets.only(top: 4, right: 12),
              decoration: BoxDecoration(
                color: isUnread
                    ? accent
                    : (isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(_typeIcon(item.type), size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: isUnread ? 0.9 : 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.45),
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'issue_created':
        return Icons.flag_rounded;
      case 'issue_status_changed':
        return Icons.autorenew_rounded;
      case 'issue_comment_added':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  static Color _typeColor(String type) {
    switch (type) {
      case 'issue_created':
        return const Color(0xFF2563EB);
      case 'issue_status_changed':
        return const Color(0xFFF59E0B);
      case 'issue_comment_added':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6366F1);
    }
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d · $hh:$mm';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? tone;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final color = tone ?? const Color(0xFF2563EB);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : const Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
