import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/core/widgets/app_logo_image.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/providers/citizen_home_providers.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/widgets/home_widgets.dart';
import 'package:sajilofix/features/notifications/presentation/providers/notification_providers.dart';
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
    final statsAsync = ref.watch(citizenHomeStatsProvider);
    final unreadAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

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
                      child: const AppLogoImage(height: 100),
                    ),
                    const Spacer(),
                    // Notification bell
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2330)
                              : Colors.white,
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
                            if (unreadCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                child: statsAsync.when(
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
                  data: (stats) {
                    return _buildStatsRow(
                      total: '${stats.total}',
                      resolved: '${stats.resolved}',
                      pending: '${stats.pending}',
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
                    HomeCategoryCard(
                      icon: Icons.construction_rounded,
                      label: 'Road Damage',
                      color: Color(0xFFEF4444),
                    ),
                    HomeCategoryCard(
                      icon: Icons.lightbulb_rounded,
                      label: 'Street Light',
                      color: Color(0xFFF59E0B),
                    ),
                    HomeCategoryCard(
                      icon: Icons.water_drop_rounded,
                      label: 'Water',
                      color: Color(0xFF3B82F6),
                    ),
                    HomeCategoryCard(
                      icon: Icons.delete_outline_rounded,
                      label: 'Garbage',
                      color: Color(0xFF10B981),
                    ),
                    HomeCategoryCard(
                      icon: Icons.park_rounded,
                      label: 'Parks',
                      color: Color(0xFF8B5CF6),
                    ),
                    HomeCategoryCard(
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
                        return HomeActivityCard(
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
                    HomeReportCard(
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
          child: HomeStatCard(
            value: total,
            label: 'Total Reports',
            icon: Icons.assignment_outlined,
            gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HomeStatCard(
            value: resolved,
            label: 'Resolved',
            icon: Icons.check_circle_outline,
            gradient: const [Color(0xFF059669), Color(0xFF047857)],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HomeStatCard(
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
