import 'package:flutter/material.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';

class ReportViewPage extends StatelessWidget {
  final IssueReport report;

  const ReportViewPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final photoUrls = report.photos
        .map((path) => _buildIssuePhotoUrl(ApiEndpoints.baseUrl, path))
        .whereType<String>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photoUrls.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: photoUrls.length,
                    itemBuilder: (context, index) {
                      final url = photoUrls[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF1F5F9),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                report.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _PillChip(
                    label: _statusLabel(report.status),
                    color: _statusColor(report.status),
                  ),
                  _PillChip(
                    label: _urgencyLabel(report.urgency),
                    color: _urgencyColor(report.urgency),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Category', value: report.category),
              _InfoRow(label: 'Status', value: _statusLabel(report.status)),
              _InfoRow(label: 'Urgency', value: _urgencyLabel(report.urgency)),
              _InfoRow(label: 'Reported', value: _timeAgo(report.createdAt)),
              const SizedBox(height: 12),
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                _formatLocation(report.location),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                report.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _buildIssuePhotoUrl(String baseUrl, String? path) {
    final rel = (path ?? '').trim();
    if (rel.isEmpty) return null;

    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');

    if (cleanRel.startsWith('uploads/')) {
      return '$cleanBase/$cleanRel';
    }

    return '$cleanBase/uploads/$cleanRel';
  }

  static String _formatLocation(IssueLocation location) {
    final parts = <String>[];
    if (location.address.trim().isNotEmpty) parts.add(location.address.trim());
    if (location.ward.trim().isNotEmpty) parts.add('Ward ${location.ward}');
    if (location.municipality.trim().isNotEmpty) {
      parts.add(location.municipality.trim());
    }
    if (location.district.trim().isNotEmpty)
      parts.add(location.district.trim());
    if ((location.landmark ?? '').trim().isNotEmpty) {
      parts.add('Near ${location.landmark!.trim()}');
    }
    return parts.isEmpty ? '-' : parts.join(', ');
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
