import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/pages/reporter_profile_page.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/features/report/presentation/widgets/report_view/report_view_widgets.dart';

const _defaultCenter = LatLng(27.7172, 85.3240);

class ReportViewPage extends ConsumerStatefulWidget {
  final IssueReport report;
  final bool allowStatusUpdate;

  const ReportViewPage({
    super.key,
    required this.report,
    this.allowStatusUpdate = false,
  });

  @override
  ConsumerState<ReportViewPage> createState() => _ReportViewPageState();
}

class _ReportViewPageState extends ConsumerState<ReportViewPage>
    with TickerProviderStateMixin {
  late String _status;
  String? _statusUpdatedByRole;
  DateTime? _statusUpdatedAt;
  bool _updating = false;
  int _photoIndex = 0;

  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _status = widget.report.status;
    _statusUpdatedByRole = widget.report.statusUpdatedByRole;
    _statusUpdatedAt = widget.report.statusUpdatedAt;
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (_status.trim().toLowerCase()) {
      case 'pending':
        return const Color(0xFF9CA3AF);
      case 'in_progress':
        return const Color(0xFFF97316);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get _statusLabel {
    switch (_status.trim().toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return _status;
    }
  }

  IconData get _statusIcon {
    switch (_status.trim().toLowerCase()) {
      case 'pending':
        return Icons.radio_button_checked_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  static Color _urgencyColor(String u) {
    switch (u.trim().toLowerCase()) {
      case 'low':
        return const Color(0xFF3B82F6);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFF97316);
      case 'urgent':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static String _urgencyLabel(String u) {
    switch (u.trim().toLowerCase()) {
      case 'low':
        return 'Low Priority';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High Priority';
      case 'urgent':
        return 'Urgent!';
      default:
        return u;
    }
  }

  static String _timeAgo(DateTime? dt) {
    if (dt == null) return 'Just now';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${(d.inDays / 7).floor()}w ago';
  }

  static String? _buildPhotoUrl(String base, String? path) {
    final rel = (path ?? '').trim();
    if (rel.isEmpty) return null;
    final b = base.replaceAll(RegExp(r'/+$'), '');
    final r = rel.replaceAll(RegExp(r'^/+'), '');
    return r.startsWith('uploads/') ? '$b/$r' : '$b/uploads/$r';
  }

  void _openPhotoViewer(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    if (photos.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportPhotoViewerPage(
          photos: photos,
          initialIndex: initialIndex.clamp(0, photos.length - 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final report = widget.report;
    final currentUserEmail = ref.watch(currentUserProvider).valueOrNull?.email;
    final photos = report.photos
        .map((p) => _buildPhotoUrl(ApiEndpoints.baseUrl, p))
        .whereType<String>()
        .toList();
    final urgColor = _urgencyColor(report.urgency);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF080B12)
            : const Color(0xFFF0F2F8),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ReportViewPhotoHero(
                    photos: photos,
                    currentIndex: _photoIndex,
                    onPageChanged: (i) => setState(() => _photoIndex = i),
                    urgencyLabel: _urgencyLabel(report.urgency),
                    urgencyColor: urgColor,
                    isDark: isDark,
                    onBack: () => Navigator.pop(context),
                    onPhotoTap: (i) => _openPhotoViewer(context, photos, i),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.15,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0A0F1E),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            ReportViewMetaChip(
                              icon: _statusIcon,
                              label: _statusLabel,
                              color: _statusColor,
                            ),
                            const SizedBox(width: 8),
                            ReportViewMetaChip(
                              icon: Icons.bolt_rounded,
                              label: _urgencyLabel(report.urgency),
                              color: urgColor,
                            ),
                            const Spacer(),
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _timeAgo(report.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white30
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: ReportViewStatsRow(
                      report: report,
                      isDark: isDark,
                      urgColor: urgColor,
                      statusColor: _statusColor,
                      onPhotosTap: photos.isEmpty
                          ? null
                          : () =>
                                _openPhotoViewer(context, photos, _photoIndex),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: ReportViewDescriptionBlock(
                      text: report.description,
                      isDark: isDark,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: ReportViewLocationBlock(
                      report: report,
                      isDark: isDark,
                      pinColor: _statusColor,
                      onExpand: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IssueMapFullScreenPage(
                            title: report.title,
                            location: report.location,
                            pinColor: _statusColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.allowStatusUpdate)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: ReportViewStatusUpdater(
                        currentStatus: _status,
                        updating: _updating,
                        isDark: isDark,
                        onChanged: (v) async {
                          if (v == null || v == _status) return;
                          setState(() => _updating = true);
                          try {
                            await ref
                                .read(adminIssuesControllerProvider.notifier)
                                .updateIssueStatus(id: report.id, status: v);
                            if (!mounted) return;
                            final roleIndex = ref
                                .read(currentUserProvider)
                                .valueOrNull
                                ?.roleIndex;
                            setState(() {
                              _status = v;
                              _statusUpdatedByRole = _roleLabelForIndex(
                                roleIndex,
                                fallback: _statusUpdatedByRole,
                              );
                              _statusUpdatedAt = DateTime.now();
                            });
                          } finally {
                            if (mounted) setState(() => _updating = false);
                          }
                        },
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: ReportViewTimeline(
                      status: _status,
                      reporterName: report.reporter?.fullName,
                      reporterEmail: report.reporter?.email,
                      currentUserEmail: currentUserEmail,
                      statusUpdatedByRole: _statusUpdatedByRole,
                      isDark: isDark,
                    ),
                  ),
                ),
                if (report.reporter != null &&
                    report.reporter!.fullName.trim().isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                      child: ReportViewReporterStrip(
                        reporter: report.reporter!,
                        photoUrl: _buildPhotoUrl(
                          ApiEndpoints.baseUrl,
                          report.reporter!.profilePhoto,
                        ),
                        isDark: isDark,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ReporterProfilePage(reporter: report.reporter!),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_statusUpdatedByRole != null || _statusUpdatedAt != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                      child: ReportViewStatusUpdateInfoCard(
                        status: _status,
                        statusUpdatedByRole: _statusUpdatedByRole,
                        statusUpdatedAt: _statusUpdatedAt,
                        isDark: isDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _roleLabelForIndex(int? roleIndex, {String? fallback}) {
    if (roleIndex == 1) return 'admin';
    if (roleIndex == 2) return 'authority';
    return fallback;
  }
}

class ReportPhotoViewerPage extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const ReportPhotoViewerPage({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<ReportPhotoViewerPage> createState() => _ReportPhotoViewerPageState();
}

class _ReportPhotoViewerPageState extends State<ReportPhotoViewerPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.photos[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white38,
                    size: 42,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.photos.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _index ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '${_index + 1} / ${widget.photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class IssueMapFullScreenPage extends StatelessWidget {
  final String title;
  final IssueLocation location;
  final Color pinColor;

  const IssueMapFullScreenPage({
    super.key,
    required this.title,
    required this.location,
    required this.pinColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lat = location.latitude;
    final lng = location.longitude;
    final center = (lat != null && lng != null)
        ? LatLng(lat, lng)
        : _defaultCenter;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sajilofix.app',
              ),
              if (lat != null && lng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.location_pin,
                        color: pinColor,
                        size: 42,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: topPad + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF111520).withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: isDark ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF111520).withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0A0F1E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
