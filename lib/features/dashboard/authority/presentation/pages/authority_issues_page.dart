import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/pages/report_view_page.dart';
import 'package:sajilofix/features/report/presentation/pages/reporter_profile_page.dart';
import 'package:sajilofix/features/dashboard/authority/presentation/providers/authority_issues_providers.dart';

class AuthorityIssuesScreen extends ConsumerStatefulWidget {
  const AuthorityIssuesScreen({super.key});

  @override
  ConsumerState<AuthorityIssuesScreen> createState() =>
      _AuthorityIssuesScreenState();
}

class _AuthorityIssuesScreenState extends ConsumerState<AuthorityIssuesScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.6);
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Hero(
                      tag: HeroTags.appLogo,
                      child: Image.asset(
                        'assets/images/sajilofix_logo.png',
                        height: 58,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => ref
                          .read(authorityIssuesControllerProvider.notifier)
                          .refresh(),
                      icon: Icon(Icons.refresh_rounded, color: onSurface),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Text(
                  'Issue Control',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      active: _statusFilter == 'all',
                      onTap: () => setState(() => _statusFilter = 'all'),
                    ),
                    _FilterChip(
                      label: 'Pending',
                      active: _statusFilter == 'pending',
                      onTap: () => setState(() => _statusFilter = 'pending'),
                      tone: const Color(0xFF94A3B8),
                    ),
                    _FilterChip(
                      label: 'In Progress',
                      active: _statusFilter == 'in_progress',
                      onTap: () =>
                          setState(() => _statusFilter = 'in_progress'),
                      tone: const Color(0xFFF59E0B),
                    ),
                    _FilterChip(
                      label: 'Resolved',
                      active: _statusFilter == 'resolved',
                      onTap: () => setState(() => _statusFilter = 'resolved'),
                      tone: const Color(0xFF22C55E),
                    ),
                    _FilterChip(
                      label: 'Rejected',
                      active: _statusFilter == 'rejected',
                      onTap: () => setState(() => _statusFilter = 'rejected'),
                      tone: const Color(0xFFEF4444),
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
                final filtered = _applyFilter(issues, _statusFilter);
                final mapData = _buildMapData(
                  filtered.isEmpty ? issues : filtered,
                );

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _GlassCard(
                        child: _IssuesMap(
                          center: mapData.center,
                          markers: mapData.markers,
                          onOpenFullMap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _FullScreenIssuesMapPage(
                                  center: mapData.center,
                                  markers: mapData.markers,
                                  title: 'Authority Issues Map',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: _GlassCard(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No matching reports.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filtered.map(
                        (issue) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: _IssueCard(
                            issue: issue,
                            onView: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReportViewPage(
                                  report: issue,
                                  allowStatusUpdate: true,
                                ),
                              ),
                            ),
                            onReporterTap: issue.reporter == null
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReporterProfilePage(
                                        reporter: issue.reporter!,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static List<IssueReport> _applyFilter(
    List<IssueReport> issues,
    String status,
  ) {
    if (status == 'all') return issues;
    return issues
        .where((issue) => issue.status.trim().toLowerCase() == status)
        .toList();
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
    final color = tone ?? const Color(0xFF38E7FF);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.6)
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

class _IssueCard extends StatelessWidget {
  final IssueReport issue;
  final VoidCallback onView;
  final VoidCallback? onReporterTap;

  const _IssueCard({
    required this.issue,
    required this.onView,
    required this.onReporterTap,
  });

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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.6);
    final avatarBg = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFEEF2FF);
    final photoUrl = _buildIssuePhotoUrl(
      ApiEndpoints.baseUrl,
      issue.photos.isNotEmpty ? issue.photos.first : null,
    );

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IssueThumbnail(
                photoUrl: photoUrl,
                isDark: theme.brightness == Brightness.dark,
                color: const Color(0xFF38E7FF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  issue.title,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusChip(label: statusLabel, tone: _chipColor(status)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            issue.location.address,
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (issue.reporter != null)
            GestureDetector(
              onTap: onReporterTap,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: avatarBg,
                    backgroundImage: _reporterPhotoUrl(issue.reporter!) == null
                        ? null
                        : NetworkImage(_reporterPhotoUrl(issue.reporter!)!),
                    child: (issue.reporter!.profilePhoto ?? '').isEmpty
                        ? Text(
                            issue.reporter!.fullName
                                .trim()
                                .characters
                                .take(1)
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      issue.reporter!.fullName,
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: muted),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: onSurface,
                    side: BorderSide(color: muted),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  showMySnackBar(
                    context: context,
                    message: 'Open report to update status',
                  );
                },
                icon: Icon(Icons.tune_rounded, color: onSurface),
              ),
            ],
          ),
        ],
      ),
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

  static String? _reporterPhotoUrl(ReporterInfo reporter) {
    final rel = (reporter.profilePhoto ?? '').trim();
    if (rel.isEmpty) return null;
    final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final clean = rel.replaceAll(RegExp(r'^/+'), '');
    return clean.startsWith('uploads/')
        ? '$base/$clean'
        : '$base/uploads/$clean';
  }

  static String? _buildIssuePhotoUrl(String baseUrl, String? path) {
    final rel = (path ?? '').trim();
    if (rel.isEmpty) return null;
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final clean = rel.replaceAll(RegExp(r'^/+'), '');
    if (clean.startsWith('uploads/')) return '$cleanBase/$clean';
    return '$cleanBase/uploads/$clean';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color tone;

  const _StatusChip({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IssueThumbnail extends StatelessWidget {
  final String? photoUrl;
  final bool isDark;
  final Color color;

  const _IssueThumbnail({
    required this.photoUrl,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _fallback(showLoader: true);
          },
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback({bool showLoader = false}) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.16)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: showLoader
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(Icons.photo_outlined, color: color),
    );
  }
}

class _IssuesMap extends StatelessWidget {
  final LatLng center;
  final List<Marker> markers;
  final VoidCallback onOpenFullMap;

  const _IssuesMap({
    required this.center,
    required this.markers,
    required this.onOpenFullMap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          ClipRRect(
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
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onOpenFullMap,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.open_in_full_rounded, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenIssuesMapPage extends StatelessWidget {
  final LatLng center;
  final List<Marker> markers;
  final String title;

  const _FullScreenIssuesMapPage({
    required this.center,
    required this.markers,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
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
