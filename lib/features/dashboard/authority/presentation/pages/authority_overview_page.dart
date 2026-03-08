import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/pages/report_view_page.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/providers/authority_issues_providers.dart';

class AuthorityOverviewScreen extends ConsumerWidget {
  const AuthorityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.6);
    final primary = theme.colorScheme.primary;
    final issuesAsync = ref.watch(authorityIssuesControllerProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Hero(
                      tag: HeroTags.appLogo,
                      child: Image.asset(
                        'assets/images/sajilofix_logo.png',
                        height: 64,
                      ),
                    ),
                    const Spacer(),
                    _GlowChip(label: 'Authority', tone: primary),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authority Overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Monitor reports, resolve urgent issues, and keep the city safe.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            issuesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _GlassCard(
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
                              .read(authorityIssuesControllerProvider.notifier)
                              .refresh(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (issues) {
                final counts = _statusCounts(issues);
                final mapData = _buildMapData(issues);
                final latest = issues.take(3).toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _StatsGrid(counts: counts),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _GlassCard(
                        child: _IssuesMap(
                          center: mapData.center,
                          markers: mapData.markers,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Recent Reports',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRoutes.authorityDashboard,
                                        (route) => false,
                                        arguments: 1,
                                      ),
                                  child: const Text('View all'),
                                ),
                              ],
                            ),
                            if (latest.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'No reports yet.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: muted,
                                  ),
                                ),
                              )
                            else
                              ...latest.map(
                                (issue) => _MiniIssueTile(
                                  issue: issue,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReportViewPage(
                                        report: issue,
                                        allowStatusUpdate: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Map<String, int> _statusCounts(List<IssueReport> issues) {
    final counts = <String, int>{
      'pending': 0,
      'in_progress': 0,
      'resolved': 0,
      'rejected': 0,
    };
    for (final issue in issues) {
      final key = issue.status.trim().toLowerCase();
      counts.update(key, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  static _MapData _buildMapData(List<IssueReport> issues) {
    final points = <LatLng>[];
    final markers = <Marker>[];

    for (final issue in issues) {
      final lat = issue.location.latitude;
      final lng = issue.location.longitude;
      if (lat == null || lng == null) continue;
      final point = LatLng(lat, lng);
      points.add(point);
      final color = _statusColor(issue.status);
      markers.add(
        Marker(
          point: point,
          width: 34,
          height: 34,
          child: Icon(Icons.location_on_rounded, color: color, size: 30),
        ),
      );
    }

    final center = points.isEmpty
        ? const LatLng(27.7172, 85.3240)
        : points[math.max(0, points.length ~/ 2)];

    return _MapData(center: center, markers: markers);
  }

  static Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return const Color(0xFF94A3B8);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, int> counts;

  const _StatsGrid({required this.counts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Pending',
            value: counts['pending']?.toString() ?? '0',
            tone: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'In Progress',
            value: counts['in_progress']?.toString() ?? '0',
            tone: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Resolved',
            value: counts['resolved']?.toString() ?? '0',
            tone: const Color(0xFF22C55E),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _StatTile({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: tone,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIssueTile extends StatelessWidget {
  final IssueReport issue;
  final VoidCallback onTap;

  const _MiniIssueTile({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = issue.status.trim().toLowerCase();
    final statusLabel = switch (status) {
      'pending' => 'Pending',
      'in_progress' => 'In Progress',
      'resolved' => 'Resolved',
      'rejected' => 'Rejected',
      _ => issue.status,
    };
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        issue.title,
        style: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        issue.location.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.55),
          fontSize: 12,
        ),
      ),
      trailing: _GlowChip(label: statusLabel, tone: _chipColor(status)),
    );
  }

  static Color _chipColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFF94A3B8);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

class _IssuesMap extends StatelessWidget {
  final LatLng center;
  final List<Marker> markers;

  const _IssuesMap({required this.center, required this.markers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sajilofix.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}

class _GlowChip extends StatelessWidget {
  final String label;
  final Color tone;

  const _GlowChip({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
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
      child: child,
    );
  }
}

class _MapData {
  final LatLng center;
  final List<Marker> markers;

  const _MapData({required this.center, required this.markers});
}
