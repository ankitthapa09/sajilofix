import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/pages/report_view_page.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class AdminIssuesScreen extends ConsumerStatefulWidget {
  const AdminIssuesScreen({super.key});

  @override
  ConsumerState<AdminIssuesScreen> createState() => _AdminIssuesScreenState();
}

class _AdminIssuesScreenState extends ConsumerState<AdminIssuesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final issuesAsync = ref.watch(adminIssuesControllerProvider);

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Hero(
                tag: HeroTags.appLogo,
                child: Image.asset(
                  'assets/images/sajilofix_logo.png',
                  height: 60,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    ref.read(adminIssuesControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Issues',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track reports and assign actions to authorities.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    issuesAsync.when(
      loading: () {
        slivers.add(
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      },
      error: (error, _) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                children: [
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => ref
                        .read(adminIssuesControllerProvider.notifier)
                        .refresh(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (issues) {
        final counts = _statusCounts(issues);

        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _IssueMetric(
                    label: 'Pending',
                    value: counts['pending']?.toString() ?? '0',
                  ),
                  const SizedBox(width: 12),
                  _IssueMetric(
                    label: 'In Progress',
                    value: counts['in_progress']?.toString() ?? '0',
                  ),
                  const SizedBox(width: 12),
                  _IssueMetric(
                    label: 'Resolved',
                    value: counts['resolved']?.toString() ?? '0',
                  ),
                ],
              ),
            ),
          ),
        );

        if (issues.isEmpty) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No issues reported yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          return;
        }

        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final issue = issues[index];
                return _IssueCard(
                  issue: issue,
                  isDark: isDark,
                  onView: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportViewPage(
                        report: issue,
                        allowStatusUpdate: true,
                      ),
                    ),
                  ),
                  onStatusChange: (status) async {
                    try {
                      await ref
                          .read(adminIssuesControllerProvider.notifier)
                          .updateIssueStatus(id: issue.id, status: status);
                    } catch (e) {
                      if (!context.mounted) return;
                      showMySnackBar(
                        context: context,
                        message: e.toString(),
                        isError: true,
                        icon: Icons.error_outline,
                      );
                    }
                  },
                  onDelete: () async {
                    final confirmed = await _confirmDelete(context);
                    if (!confirmed) return;
                    try {
                      await ref
                          .read(adminIssuesControllerProvider.notifier)
                          .deleteIssue(issue.id);
                    } catch (e) {
                      if (!context.mounted) return;
                      showMySnackBar(
                        context: context,
                        message: e.toString(),
                        isError: true,
                        icon: Icons.error_outline,
                      );
                    }
                  },
                );
              }, childCount: issues.length),
            ),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: slivers,
        ),
      ),
    );
  }

  static Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete issue?'),
        content: const Text(
          'This will permanently remove the issue and its history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Map<String, int> _statusCounts(List<IssueReport> issues) {
    var pending = 0, progress = 0, resolved = 0;
    for (final issue in issues) {
      switch (issue.status.trim().toLowerCase()) {
        case 'pending':
          pending++;
          break;
        case 'in_progress':
          progress++;
          break;
        case 'resolved':
          resolved++;
          break;
      }
    }
    return {'pending': pending, 'in_progress': progress, 'resolved': resolved};
  }
}

class _IssueMetric extends StatelessWidget {
  final String label;
  final String value;

  const _IssueMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IssueReport issue;
  final bool isDark;
  final VoidCallback onView;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onDelete;

  const _IssueCard({
    required this.issue,
    required this.isDark,
    required this.onView,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(issue.status);
    final location = _formatLocation(issue.location);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${location.isEmpty ? 'Unknown' : location} · ${_timeAgo(issue.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(issue.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View'),
              ),
              const SizedBox(width: 12),
              _StatusMenu(value: issue.status, onChanged: onStatusChange),
              const Spacer(),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatLocation(IssueLocation location) {
    final parts = <String>[];
    if (location.municipality.trim().isNotEmpty) {
      parts.add(location.municipality.trim());
    }
    if (location.ward.trim().isNotEmpty) {
      parts.add('Ward ${location.ward}');
    }
    if (location.district.trim().isNotEmpty) {
      parts.add(location.district.trim());
    }
    return parts.join(', ');
  }

  static String _statusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  static Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return const Color(0xFFE53E3E);
      case 'in_progress':
        return const Color(0xFFF97316);
      case 'resolved':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static String _timeAgo(DateTime? createdAt) {
    if (createdAt == null) return 'Just now';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'about ${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks weeks ago';
  }
}

class _StatusMenu extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _StatusMenu({required this.value, required this.onChanged});

  static const _statuses = <String>[
    'pending',
    'in_progress',
    'resolved',
    'rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Update status',
      onSelected: onChanged,
      itemBuilder: (_) => _statuses
          .map(
            (s) =>
                PopupMenuItem<String>(value: s, child: Text(_statusLabel(s))),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_outlined, size: 16),
            const SizedBox(width: 6),
            Text(
              _statusLabel(value),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
