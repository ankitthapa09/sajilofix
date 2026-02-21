import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final fullName = currentUserAsync.maybeWhen(
      data: (user) => user?.fullName,
      orElse: () => null,
    );
    final reportsAsync = ref.watch(myReportsProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Hero(
                      tag: HeroTags.appLogo,
                      child: Image.asset(
                        'assets/images/sajilofix_logo.png',
                        height: 100,
                      ),
                    ),
                    const Spacer(),
                    // Notification bell
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2330) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 22,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          Positioned(
                            top: 9,
                            right: 9,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${_firstName(fullName)} 👋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F1117),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Help keep your community clean & safe.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: reportsAsync.when(
                  loading: () => _buildStatsRow(
                    total: '-',
                    resolved: '-',
                    pending: '-',
                    isDark: isDark,
                  ),
                  error: (_, __) => _buildStatsRow(
                    total: '-',
                    resolved: '-',
                    pending: '-',
                    isDark: isDark,
                  ),
                  data: (reports) {
                    final total = reports.length;
                    final resolved = _countStatus(reports, const {'resolved'});
                    final pending = _countStatus(reports, const {
                      'pending',
                      'in_progress',
                    });
                    return _buildStatsRow(
                      total: '$total',
                      resolved: '$resolved',
                      pending: '$pending',
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F1117), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circle
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2563EB,
                                    ).withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '⚡ Quick Report',
                                    style: TextStyle(
                                      color: Color(0xFF93C5FD),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Report an Issue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Snap a photo and submit instantly.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () => Navigator.of(context)
                                      .pushReplacementNamed(
                                        AppRoutes.dashboard,
                                        arguments: 1,
                                      ),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF2563EB,
                                          ).withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Report Now',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF0F1117),
                      ),
                    ),
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  children: const [
                    _CategoryCard(
                      icon: Icons.construction_rounded,
                      label: 'Road Damage',
                      color: Color(0xFFEF4444),
                    ),
                    _CategoryCard(
                      icon: Icons.lightbulb_rounded,
                      label: 'Street Light',
                      color: Color(0xFFF59E0B),
                    ),
                    _CategoryCard(
                      icon: Icons.water_drop_rounded,
                      label: 'Water',
                      color: Color(0xFF3B82F6),
                    ),
                    _CategoryCard(
                      icon: Icons.delete_outline_rounded,
                      label: 'Garbage',
                      color: Color(0xFF10B981),
                    ),
                    _CategoryCard(
                      icon: Icons.park_rounded,
                      label: 'Parks',
                      color: Color(0xFF8B5CF6),
                    ),
                    _CategoryCard(
                      icon: Icons.more_horiz_rounded,
                      label: 'Other',
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF0F1117),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'Live',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: reportsAsync.when(
                  loading: () => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => const Center(
                    child: Text('Unable to load recent activity'),
                  ),
                  data: (reports) {
                    final items = _sortedReports(reports).take(5).toList();
                    if (items.isEmpty) {
                      return const Center(child: Text('No activity yet'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final report = items[index];
                        final status = _statusStyle(report.status);
                        final category = _categoryStyle(report.category);
                        return _ActivityCard(
                          title: report.title,
                          location: _formatLocation(report.location),
                          time: _relativeTime(report.createdAt),
                          status: status.label,
                          statusColor: status.color,
                          statusBg: status.bg,
                          icon: category.icon,
                          iconColor: category.color,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Your Reports header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Reports',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF0F1117),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.dashboard, arguments: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Your Report Cards
            reportsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Center(child: Text('Unable to load your reports')),
                ),
              ),
              data: (reports) {
                final items = _sortedReports(reports).take(3).toList();
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: Center(child: Text('No reports yet')),
                    ),
                  );
                }
                final tiles = <Widget>[];
                for (var i = 0; i < items.length; i++) {
                  final report = items[i];
                  final status = _statusStyle(report.status);
                  final category = _categoryStyle(report.category);
                  tiles.add(
                    _ReportCard(
                      title: report.title,
                      location: _formatLocation(report.location),
                      date: _formatDate(report.createdAt),
                      status: status.label,
                      statusColor: status.color,
                      statusBg: status.bg,
                      photoUrl: _buildIssuePhotoUrl(
                        ApiEndpoints.baseUrl,
                        report.photos.isNotEmpty ? report.photos.first : null,
                      ),
                      icon: category.icon,
                      iconColor: category.color,
                      iconBg: category.bg,
                      isDark: isDark,
                    ),
                  );
                  if (i != items.length - 1) {
                    tiles.add(const SizedBox(height: 12));
                  }
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  sliver: SliverList(delegate: SliverChildListDelegate(tiles)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _firstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'User';
    return fullName.trim().split(' ').first;
  }

  Widget _buildStatsRow({
    required String total,
    required String resolved,
    required String pending,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: total,
            label: 'Total Reports',
            icon: Icons.assignment_outlined,
            gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: resolved,
            label: 'Resolved',
            icon: Icons.check_circle_outline,
            gradient: const [Color(0xFF059669), Color(0xFF047857)],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: pending,
            label: 'Pending',
            icon: Icons.hourglass_empty_rounded,
            gradient: const [Color(0xFFD97706), Color(0xFFB45309)],
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  int _countStatus(List<IssueReport> reports, Set<String> statuses) {
    var count = 0;
    for (final report in reports) {
      final status = report.status.trim().toLowerCase();
      if (statuses.contains(status)) {
        count++;
      }
    }
    return count;
  }

  List<IssueReport> _sortedReports(List<IssueReport> reports) {
    final items = List<IssueReport>.from(reports);
    items.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return items;
  }

  ({String label, Color color, Color bg}) _statusStyle(String status) {
    switch (status.trim().toLowerCase()) {
      case 'resolved':
        return (
          label: 'Resolved',
          color: const Color(0xFF059669),
          bg: const Color(0xFFDCFCE7),
        );
      case 'in_progress':
        return (
          label: 'In Progress',
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFDBEAFE),
        );
      default:
        return (
          label: 'Pending',
          color: const Color(0xFFD97706),
          bg: const Color(0xFFFEF3C7),
        );
    }
  }

  ({IconData icon, Color color, Color bg}) _categoryStyle(String category) {
    final key = category
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[_\s]+'), ' ');
    switch (key) {
      case 'roads and potholes':
      case 'roads potholes':
        return (
          icon: Icons.construction_rounded,
          color: const Color(0xFFEF4444),
          bg: const Color(0xFFFEE2E2),
        );
      case 'street lights':
      case 'street light':
        return (
          icon: Icons.lightbulb_rounded,
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFEF9C3),
        );
      case 'water supply':
      case 'water':
        return (
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF3B82F6),
          bg: const Color(0xFFDBEAFE),
        );
      case 'waste management':
      case 'garbage':
        return (
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFF10B981),
          bg: const Color(0xFFD1FAE5),
        );
      case 'public infrastructure':
        return (
          icon: Icons.apartment_rounded,
          color: const Color(0xFF8B5CF6),
          bg: const Color(0xFFEDE9FE),
        );
      case 'electricity':
        return (
          icon: Icons.bolt_rounded,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFE0F2FE),
        );
      default:
        return (
          icon: Icons.more_horiz_rounded,
          color: const Color(0xFF6B7280),
          bg: const Color(0xFFF3F4F6),
        );
    }
  }

  String _formatLocation(IssueLocation location) {
    final pieces = <String>[];
    if (location.address.trim().isNotEmpty) {
      pieces.add(location.address.trim());
    }
    if (location.municipality.trim().isNotEmpty) {
      pieces.add(location.municipality.trim());
    }
    if (location.district.trim().isNotEmpty) {
      pieces.add(location.district.trim());
    }
    return pieces.isEmpty ? '-' : pieces.join(', ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  String _relativeTime(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '${weeks}w ago';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';
    final years = (diff.inDays / 365).floor();
    return '${years}y ago';
  }

  String? _buildIssuePhotoUrl(String baseUrl, String? path) {
    final rel = (path ?? '').trim();
    if (rel.isEmpty) return null;
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRel = rel.replaceAll(RegExp(r'^/+'), '');
    if (cleanRel.startsWith('uploads/')) return '$cleanBase/$cleanRel';
    return '$cleanBase/uploads/$cleanRel';
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Category Card (horizontal scroll)
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

// Activity Card (horizontal scroll)

class _ActivityCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _ActivityCard({
    required this.title,
    required this.location,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            location,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? statusColor.withValues(alpha: 0.15) : statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
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

// Report Card (vertical list)

class _ReportCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String? photoUrl;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isDark;

  const _ReportCard({
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.photoUrl,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icon box
          _ReportLeading(
            photoUrl: photoUrl,
            icon: icon,
            iconColor: iconColor,
            iconBg: iconBg,
            isDark: isDark,
          ),
          const SizedBox(width: 14),

          // Title with location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white30 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? statusColor.withValues(alpha: 0.15) : statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
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

class _ReportLeading extends StatelessWidget {
  final String? photoUrl;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isDark;

  const _ReportLeading({
    required this.photoUrl,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    final showImage = url.isNotEmpty;
    if (showImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _fallbackIcon(showLoader: true);
          },
        ),
      );
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon({bool showLoader = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: showLoader
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            )
          : Icon(icon, color: iconColor, size: 22),
    );
  }
}
