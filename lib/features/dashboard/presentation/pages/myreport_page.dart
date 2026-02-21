import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/pages/report_view_page.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class MyreportScreen extends ConsumerStatefulWidget {
  const MyreportScreen({super.key});

  @override
  ConsumerState<MyreportScreen> createState() => _MyreportScreenState();
}

class _MyreportScreenState extends ConsumerState<MyreportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchField(controller: _searchController),
              const SizedBox(height: 12),
              reportsAsync.when(
                data: (reports) {
                  final filtered = _applyFilters(reports);
                  final counts = _statusCounts(reports);

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterTabs(
                          counts: counts,
                          selected: _selectedFilter,
                          onSelected: (value) {
                            setState(() => _selectedFilter = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: filtered.isEmpty
                              ? _EmptyState(
                                  onRefresh: () {
                                    ref.invalidate(myReportsProvider);
                                  },
                                )
                              : ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final report = filtered[index];
                                    return _ReportCard(
                                      report: report,
                                      photoUrl: _buildIssuePhotoUrl(
                                        ApiEndpoints.baseUrl,
                                        report.photos.isNotEmpty
                                            ? report.photos.first
                                            : null,
                                      ),
                                      onView: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ReportViewPage(report: report),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Expanded(
                  child: _ErrorState(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(myReportsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _statusCounts(List<IssueReport> reports) {
    var reported = 0;
    var progress = 0;
    var resolved = 0;

    for (final report in reports) {
      switch (report.status.trim().toLowerCase()) {
        case 'pending':
          reported += 1;
          break;
        case 'in_progress':
          progress += 1;
          break;
        case 'resolved':
          resolved += 1;
          break;
      }
    }

    return {
      'all': reports.length,
      'reported': reported,
      'progress': progress,
      'resolved': resolved,
    };
  }

  List<IssueReport> _applyFilters(List<IssueReport> reports) {
    final query = _searchController.text.trim().toLowerCase();
    var items = reports;

    if (_selectedFilter != 'all') {
      items = items.where((report) {
        final status = report.status.trim().toLowerCase();
        switch (_selectedFilter) {
          case 'reported':
            return status == 'pending';
          case 'progress':
            return status == 'in_progress';
          case 'resolved':
            return status == 'resolved';
        }
        return true;
      }).toList();
    }

    if (query.isNotEmpty) {
      items = items.where((report) {
        final title = report.title.toLowerCase();
        final address = report.location.address.toLowerCase();
        final municipality = report.location.municipality.toLowerCase();
        return title.contains(query) ||
            address.contains(query) ||
            municipality.contains(query);
      }).toList();
    }

    return items;
  }

  String? _buildIssuePhotoUrl(String baseUrl, String? path) {
    final rel = (path ?? '').trim();
    if (rel.isEmpty) return null;

    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');

    if (cleanRel.startsWith('uploads/')) {
      return '$cleanBase/$cleanRel';
    }

    return '$cleanBase/uploads/$cleanRel';
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search my reports...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final Map<String, int> counts;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterTabs({
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = const [
      {'key': 'all', 'label': 'All'},
      {'key': 'reported', 'label': 'Reported'},
      {'key': 'progress', 'label': 'Progress'},
      {'key': 'resolved', 'label': 'Resolved'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final key = filter['key'] as String;
          final label = filter['label'] as String;
          final isSelected = selected == key;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF111827)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '$label (${counts[key] ?? 0})',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IssueReport report;
  final String? photoUrl;
  final VoidCallback onView;

  const _ReportCard({
    required this.report,
    required this.photoUrl,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(report.status);
    final statusColor = _statusColor(report.status);
    final urgencyLabel = _urgencyLabel(report.urgency);
    final urgencyColor = _urgencyColor(report.urgency);
    final timeLabel = _timeAgo(report.createdAt);
    final location = report.location.address.trim().isEmpty
        ? report.location.municipality
        : report.location.address;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportThumbnail(photoUrl: photoUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _PillChip(label: statusLabel, color: statusColor),
                    _PillChip(label: urgencyLabel, color: urgencyColor),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onView,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: const Size(64, 36),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return 'Reported';
      case 'in_progress':
        return 'Progress';
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

  static String _urgencyLabel(String urgency) {
    switch (urgency.trim().toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
    }
    return urgency;
  }

  static Color _urgencyColor(String urgency) {
    switch (urgency.trim().toLowerCase()) {
      case 'low':
        return const Color(0xFF3B82F6);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFF97316);
      case 'urgent':
        return const Color(0xFFE11D48);
    }
    return const Color(0xFF6B7280);
  }

  static String _timeAgo(DateTime? createdAt) {
    if (createdAt == null) return 'Just now';

    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return 'about ${diff.inHours} hours ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    final weeks = (diff.inDays / 7).floor();
    return '$weeks weeks ago';
  }
}

class _ReportThumbnail extends StatelessWidget {
  final String? photoUrl;

  const _ReportThumbnail({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: const Color(0xFFF1F5F9),
        child: photoUrl == null
            ? const Icon(Icons.image_outlined, color: Colors.grey)
            : Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined),
              ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final Color color;

  const _PillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'No reports yet',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your submitted reports will appear here.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 56,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
