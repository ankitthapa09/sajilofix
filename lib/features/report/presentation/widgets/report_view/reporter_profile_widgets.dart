import 'package:flutter/material.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';

class ReporterProfileHeader extends StatelessWidget {
  final ReporterInfo reporter;
  final String baseUrl;

  const ReporterProfileHeader({
    super.key,
    required this.reporter,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = buildReporterPhotoUrl(baseUrl, reporter.profilePhoto);
    final statusLabel = reporterStatusLabel(reporter.status);
    final statusColor = reporterStatusColor(reporter.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE2E8F0),
            backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
            child: photoUrl == null
                ? Text(
                    reporterInitials(reporter.fullName),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reporter.fullName.trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((reporter.email ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      reporter.email!.trim(),
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                if ((reporter.phone ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      reporter.phone!.trim(),
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReporterProfileStatusSection extends StatelessWidget {
  final ReporterInfo reporter;

  const ReporterProfileStatusSection({super.key, required this.reporter});

  @override
  Widget build(BuildContext context) {
    final statusLabel = reporterStatusLabel(reporter.status);
    final statusColor = reporterStatusColor(reporter.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(statusLabel, style: TextStyle(color: statusColor)),
      ],
    );
  }
}

String? buildReporterPhotoUrl(String baseUrl, String? path) {
  final rel = (path ?? '').trim();
  if (rel.isEmpty) return null;

  final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
  final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');

  if (cleanRel.startsWith('uploads/')) {
    return '$cleanBase/$cleanRel';
  }

  return '$cleanBase/uploads/$cleanRel';
}

String reporterInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'U';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first.characters.take(2).toString();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

String reporterStatusLabel(String? status) {
  switch ((status ?? '').trim().toLowerCase()) {
    case 'active':
      return 'Active';
    case 'inactive':
      return 'Inactive';
    case 'blocked':
      return 'Blocked';
    case 'pending':
      return 'Pending';
  }
  return (status ?? 'Unknown').trim();
}

Color reporterStatusColor(String? status) {
  switch ((status ?? '').trim().toLowerCase()) {
    case 'active':
      return const Color(0xFF16A34A);
    case 'inactive':
      return const Color(0xFF6B7280);
    case 'blocked':
      return const Color(0xFFDC2626);
    case 'pending':
      return const Color(0xFFF59E0B);
  }
  return const Color(0xFF6B7280);
}
