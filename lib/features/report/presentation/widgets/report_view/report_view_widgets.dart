import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';

class ReportViewPhotoHero extends StatelessWidget {
  final List<String> photos;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final String urgencyLabel;
  final Color urgencyColor;
  final bool isDark;
  final VoidCallback onBack;
  final ValueChanged<int> onPhotoTap;

  const ReportViewPhotoHero({
    super.key,
    required this.photos,
    required this.currentIndex,
    required this.onPageChanged,
    required this.urgencyLabel,
    required this.urgencyColor,
    required this.isDark,
    required this.onBack,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final hasPhoto = photos.isNotEmpty;

    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          Positioned.fill(
            child: hasPhoto
                ? PageView.builder(
                    itemCount: photos.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => onPhotoTap(i),
                      child: Image.network(
                        photos[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            ReportViewPlaceholderBg(isDark: isDark),
                      ),
                    ),
                  )
                : ReportViewPlaceholderBg(isDark: isDark),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.65, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                    isDark
                        ? const Color(0xFF080B12).withValues(alpha: 0.98)
                        : const Color(0xFFF0F2F8).withValues(alpha: 0.97),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + 12,
            left: 16,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: urgencyColor.withValues(alpha: 0.55)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: urgencyColor, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    urgencyLabel,
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (photos.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(photos.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentIndex ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
          if (!hasPhoto)
            Positioned(
              bottom: 22,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white38,
                      size: 12,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'No photos',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReportViewMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ReportViewMetaChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportViewReporterStrip extends StatelessWidget {
  final ReporterInfo reporter;
  final String? photoUrl;
  final bool isDark;
  final VoidCallback onTap;

  const ReportViewReporterStrip({
    super.key,
    required this.reporter,
    required this.photoUrl,
    required this.isDark,
    required this.onTap,
  });

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(reporter.fullName);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111520) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFE9ECF2),
          ),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child: (photoUrl ?? '').isNotEmpty
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reported by',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white30 : const Color(0xFF9CA3AF),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reporter.fullName.trim(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0A0F1E),
                    ),
                  ),
                  if ((reporter.email ?? '').trim().isNotEmpty)
                    Text(
                      reporter.email!.trim(),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white30
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportViewStatsRow extends StatelessWidget {
  final IssueReport report;
  final bool isDark;
  final Color urgColor;
  final Color statusColor;
  final VoidCallback? onPhotosTap;

  const ReportViewStatsRow({
    super.key,
    required this.report,
    required this.isDark,
    required this.urgColor,
    required this.statusColor,
    this.onPhotosTap,
  });

  static String _urgShort(String u) {
    switch (u.trim().toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return u;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE9ECF2),
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Issue Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0A0F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ReportViewStatCard(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: report.category,
                  color: const Color(0xFF2563EB),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReportViewStatCard(
                  icon: Icons.bolt_rounded,
                  label: 'Urgency',
                  value: _urgShort(report.urgency),
                  color: urgColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReportViewStatCard(
                  icon: Icons.photo_library_outlined,
                  label: 'Photos',
                  value: '${report.photos.length}',
                  color: const Color(0xFF7C3AED),
                  isDark: isDark,
                  onTap: onPhotosTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportViewStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const ReportViewStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0A0F1E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white30 : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

class ReportViewDescriptionBlock extends StatefulWidget {
  final String text;
  final bool isDark;

  const ReportViewDescriptionBlock({
    super.key,
    required this.text,
    required this.isDark,
  });

  @override
  State<ReportViewDescriptionBlock> createState() =>
      _ReportViewDescriptionBlockState();
}

class ReportViewTimeline extends StatelessWidget {
  final String status;
  final String? reporterName;
  final String? reporterEmail;
  final String? currentUserEmail;
  final String? statusUpdatedByRole;
  final List<IssueStatusHistoryEntry> statusHistory;
  final bool isDark;

  const ReportViewTimeline({
    super.key,
    required this.status,
    this.reporterName,
    this.reporterEmail,
    this.currentUserEmail,
    this.statusUpdatedByRole,
    this.statusHistory = const [],
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final isRejected = normalized == 'rejected';
    final activeIndex = _statusIndex(normalized);
    final steps = <_TimelineStep>[
      const _TimelineStep(
        label: 'Pending',
        icon: Icons.flag_rounded,
        color: Color(0xFF9CA3AF),
      ),
      const _TimelineStep(
        label: 'In Progress',
        icon: Icons.autorenew_rounded,
        color: Color(0xFFF97316),
      ),
      _TimelineStep(
        label: isRejected ? 'Rejected' : 'Resolved',
        icon: isRejected ? Icons.cancel_rounded : Icons.check_circle_rounded,
        color: isRejected ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      ),
    ];
    final reportedBy = _reportedByLabel(
      reporterName,
      reporterEmail,
      currentUserEmail,
    );
    final inProgressEntry = _historyByStatus(statusHistory, 'in_progress');
    final resolvedEntry = _historyByStatus(
      statusHistory,
      isRejected ? 'rejected' : 'resolved',
    );
    final inProgressBy = activeIndex >= 1
        ? _byRoleLabel(inProgressEntry?.changedByRole ?? statusUpdatedByRole)
        : null;
    final resolvedBy = activeIndex >= 2
        ? _byRoleLabel(resolvedEntry?.changedByRole ?? statusUpdatedByRole)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE9ECF2),
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Timeline',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0A0F1E),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _TimelineDot(
                step: steps[0],
                state: _stepState(0, activeIndex),
                isDark: isDark,
              ),
              _TimelineLine(color: _lineColor(0, activeIndex, steps, isDark)),
              _TimelineDot(
                step: steps[1],
                state: _stepState(1, activeIndex),
                isDark: isDark,
              ),
              _TimelineLine(color: _lineColor(1, activeIndex, steps, isDark)),
              _TimelineDot(
                step: steps[2],
                state: _stepState(2, activeIndex),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _TimelineLabel(
                  label: steps[0].label,
                  subtitle: reportedBy,
                  isActive: activeIndex >= 0,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _TimelineLabel(
                  label: steps[1].label,
                  subtitle: inProgressBy,
                  isActive: activeIndex >= 1,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _TimelineLabel(
                  label: steps[2].label,
                  subtitle: resolvedBy,
                  isActive: activeIndex >= 2,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static int _statusIndex(String status) {
    switch (status) {
      case 'in_progress':
        return 1;
      case 'resolved':
      case 'rejected':
        return 2;
      case 'pending':
      default:
        return 0;
    }
  }

  static _TimelineState _stepState(int index, int activeIndex) {
    if (index < activeIndex) return _TimelineState.completed;
    if (index == activeIndex) return _TimelineState.active;
    return _TimelineState.upcoming;
  }

  static Color _lineColor(
    int index,
    int activeIndex,
    List<_TimelineStep> steps,
    bool isDark,
  ) {
    if (index < activeIndex) return steps[index].color;
    return isDark ? Colors.white24 : const Color(0xFFE5E7EB);
  }

  static String? _reportedByLabel(
    String? name,
    String? reporterEmail,
    String? currentEmail,
  ) {
    final trimmedName = (name ?? '').trim();
    final reporterMail = (reporterEmail ?? '').trim().toLowerCase();
    final currentMail = (currentEmail ?? '').trim().toLowerCase();
    if (reporterMail.isNotEmpty && reporterMail == currentMail) {
      return 'By you';
    }
    if (trimmedName.isNotEmpty) return 'By $trimmedName';
    return null;
  }

  static String? _byRoleLabel(String? role) {
    final v = (role ?? '').trim().toLowerCase();
    if (v == 'authority') return 'By authority';
    if (v == 'admin') return 'By admin';
    return null;
  }

  static IssueStatusHistoryEntry? _historyByStatus(
    List<IssueStatusHistoryEntry> history,
    String status,
  ) {
    for (final entry in history.reversed) {
      if (entry.status.trim().toLowerCase() == status) return entry;
    }
    return null;
  }
}

class _TimelineDot extends StatelessWidget {
  final _TimelineStep step;
  final _TimelineState state;
  final bool isDark;

  const _TimelineDot({
    required this.step,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = state == _TimelineState.active;
    final isComplete = state == _TimelineState.completed;
    final color = isComplete || isActive
        ? step.color
        : (isDark ? Colors.white24 : const Color(0xFFE5E7EB));
    final fill = isComplete || isActive
        ? step.color.withValues(alpha: 0.15)
        : (isDark ? Colors.white10 : const Color(0xFFF3F4F6));

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: isActive ? 2 : 1.4),
      ),
      alignment: Alignment.center,
      child: Icon(step.icon, size: 18, color: color),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  final Color color;

  const _TimelineLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _TimelineLabel extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isActive;
  final bool isDark;

  const _TimelineLabel({
    required this.label,
    this.subtitle,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final showSubtitle = (subtitle ?? '').trim().isNotEmpty;
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive
                ? (isDark ? Colors.white : const Color(0xFF0A0F1E))
                : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!.trim(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimelineStep {
  final String label;
  final IconData icon;
  final Color color;

  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class ReportViewStatusUpdateInfoCard extends StatelessWidget {
  final String status;
  final String? statusUpdatedByRole;
  final DateTime? statusUpdatedAt;
  final bool isDark;

  const ReportViewStatusUpdateInfoCard({
    super.key,
    required this.status,
    required this.statusUpdatedByRole,
    required this.statusUpdatedAt,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final roleLabel = _roleLabel(statusUpdatedByRole);
    final timeLabel = _formatDateTime(statusUpdatedAt);
    final statusLabel = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE9ECF2),
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.update_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Last Status Update',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0A0F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (roleLabel != null)
            _InfoRow(
              icon: Icons.verified_user_rounded,
              label: roleLabel,
              isDark: isDark,
            ),
          if (statusLabel != null)
            _InfoRow(
              icon: Icons.flag_rounded,
              label: statusLabel,
              isDark: isDark,
            ),
          if (timeLabel != null)
            _InfoRow(
              icon: Icons.schedule_rounded,
              label: timeLabel,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  static String? _roleLabel(String? role) {
    final v = (role ?? '').trim().toLowerCase();
    if (v == 'admin') return 'Updated by Admin';
    if (v == 'authority') return 'Updated by Authority';
    return null;
  }

  static String? _statusLabel(String status) {
    final v = status.trim().toLowerCase();
    if (v == 'pending') return 'Status: Pending';
    if (v == 'in_progress') return 'Status: In Progress';
    if (v == 'resolved') return 'Status: Resolved';
    if (v == 'rejected') return 'Status: Rejected';
    return null;
  }

  static String? _formatDateTime(DateTime? dt) {
    if (dt == null) return null;
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d · $hh:$mm';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TimelineState { completed, active, upcoming }

class _ReportViewDescriptionBlockState
    extends State<ReportViewDescriptionBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > 180;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF111520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(
            0xFF7C3AED,
          ).withValues(alpha: widget.isDark ? 0.14 : 0.1),
        ),
        boxShadow: widget.isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.notes_rounded,
                  size: 16,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: widget.isDark ? Colors.white : const Color(0xFF0A0F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: (!isLong || _expanded)
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark ? Colors.white54 : const Color(0xFF374151),
                height: 1.65,
              ),
            ),
            secondChild: Text(
              widget.text,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark ? Colors.white54 : const Color(0xFF374151),
                height: 1.65,
              ),
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? '↑ Show less' : '↓ Read more',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ReportViewLocationBlock extends StatelessWidget {
  final IssueReport report;
  final bool isDark;
  final VoidCallback onExpand;
  final Color pinColor;

  const ReportViewLocationBlock({
    super.key,
    required this.report,
    required this.isDark,
    required this.onExpand,
    required this.pinColor,
  });

  static const _red = Color(0xFFEF4444);

  static String _fmt(IssueLocation l) {
    final p = <String>[];
    if (l.address.trim().isNotEmpty) p.add(l.address.trim());
    if (l.ward.trim().isNotEmpty) p.add('Ward ${l.ward}');
    if (l.municipality.trim().isNotEmpty) p.add(l.municipality.trim());
    if (l.district.trim().isNotEmpty) p.add(l.district.trim());
    if ((l.landmark ?? '').trim().isNotEmpty) {
      p.add('Near ${l.landmark!.trim()}');
    }
    return p.isEmpty ? 'Location not specified' : p.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final loc = report.location;
    final hasCoords = loc.latitude != null && loc.longitude != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _red.withValues(alpha: isDark ? 0.14 : 0.1)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: _red.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: _red,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0A0F1E),
                  ),
                ),
              ],
            ),
          ),
          if (hasCoords)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: ReportViewMapTile(
                center: LatLng(loc.latitude!, loc.longitude!),
                isDark: isDark,
                onExpand: onExpand,
                pinColor: pinColor,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 15,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fmt(loc),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportViewMapTile extends StatelessWidget {
  final LatLng center;
  final bool isDark;
  final VoidCallback onExpand;
  final Color pinColor;

  const ReportViewMapTile({
    super.key,
    required this.center,
    required this.isDark,
    required this.onExpand,
    required this.pinColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sajilofix.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_pin,
                        color: pinColor,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: onExpand,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF111520).withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.open_in_full_rounded,
                    size: 15,
                    color: isDark ? Colors.white70 : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportViewStatusUpdater extends StatelessWidget {
  final String currentStatus;
  final bool updating;
  final bool isDark;
  final bool lockPendingAfterProgress;
  final ValueChanged<String?> onChanged;

  const ReportViewStatusUpdater({
    super.key,
    required this.currentStatus,
    required this.updating,
    required this.isDark,
    this.lockPendingAfterProgress = false,
    required this.onChanged,
  });

  static const _opts = [
    (
      v: 'pending',
      l: 'Pending',
      i: Icons.radio_button_checked_rounded,
      c: Color(0xFF9CA3AF),
    ),
    (
      v: 'in_progress',
      l: 'In Progress',
      i: Icons.autorenew_rounded,
      c: Color(0xFFF97316),
    ),
    (
      v: 'resolved',
      l: 'Resolved',
      i: Icons.check_circle_rounded,
      c: Color(0xFF10B981),
    ),
    (
      v: 'rejected',
      l: 'Rejected',
      i: Icons.cancel_rounded,
      c: Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final normalized = currentStatus.trim().toLowerCase();
    final isPending = normalized == 'pending';
    final isInProgress = normalized == 'in_progress';
    final isResolved = normalized == 'resolved';
    final isRejected = normalized == 'rejected';
    final canSelectPending = !lockPendingAfterProgress || isPending;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(
            0xFFD97706,
          ).withValues(alpha: isDark ? 0.18 : 0.12),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: updating
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD97706),
                        ),
                      )
                    : const Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
              ),
              const SizedBox(width: 10),
              Text(
                'Update Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0A0F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _opts.map((o) {
              final isPendingOpt = o.v == 'pending';
              final isProgressOpt = o.v == 'in_progress';
              final isResolvedOpt = o.v == 'resolved';
              final isRejectedOpt = o.v == 'rejected';
              final active =
                  currentStatus == o.v || (isResolved && isProgressOpt);
              final canTap =
                  !updating &&
                  (isPendingOpt
                      ? canSelectPending
                      : isResolvedOpt
                      ? (isInProgress || isResolved)
                      : isProgressOpt
                      ? (isPending || isInProgress)
                      : isRejectedOpt
                      ? (isPending || isInProgress || isRejected)
                      : true);
              final iconColor = active
                  ? o.c
                  : (isDark ? Colors.white24 : const Color(0xFF9CA3AF));
              final labelColor = active
                  ? o.c
                  : (isDark ? Colors.white30 : const Color(0xFF9CA3AF));
              final borderColor = active
                  ? o.c.withValues(alpha: 0.5)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE9ECF2));
              final fillColor = active
                  ? o.c.withValues(alpha: isDark ? 0.2 : 0.1)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF9FAFB));
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: o == _opts.last ? 0 : 8),
                  child: GestureDetector(
                    onTap: canTap ? () => onChanged(o.v) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(o.i, size: 18, color: iconColor),
                          const SizedBox(height: 4),
                          Text(
                            o.l,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: labelColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ReportViewPlaceholderBg extends StatelessWidget {
  final bool isDark;

  const ReportViewPlaceholderBg({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF111520) : const Color(0xFFDDE1EE),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 52,
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            'No photos attached',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
