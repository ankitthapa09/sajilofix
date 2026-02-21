import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/features/dashboard/citizen/presentation/widgets/myreport_widgets.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/pages/report_view_page.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class MyreportScreen extends ConsumerStatefulWidget {
  const MyreportScreen({super.key});

  @override
  ConsumerState<MyreportScreen> createState() => _MyreportScreenState();
}

class _MyreportScreenState extends ConsumerState<MyreportScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  AnimationController? _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOut,
    );
    _animController!.forward();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF4F6FB),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            MyReportHeader(isDark: isDark),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: MyReportSearchField(
                controller: _searchController,
                isDark: isDark,
              ),
            ),

            Expanded(
              child: reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => MyReportErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(myReportsProvider),
                ),
                data: (reports) {
                  final counts = _statusCounts(reports);
                  final filtered = _applyFilters(reports);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: MyReportStatsRow(counts: counts, isDark: isDark),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
                        child: MyReportFilterTabs(
                          counts: counts,
                          selected: _selectedFilter,
                          onSelected: (v) =>
                              setState(() => _selectedFilter = v),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Expanded(
                        child: filtered.isEmpty
                            ? MyReportEmptyState(
                                onRefresh: () =>
                                    ref.invalidate(myReportsProvider),
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  32,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final report = filtered[index];
                                  return MyReportCard(
                                    report: report,
                                    photoUrl: _buildIssuePhotoUrl(
                                      ApiEndpoints.baseUrl,
                                      report.photos.isNotEmpty
                                          ? report.photos.first
                                          : null,
                                    ),
                                    isDark: isDark,
                                    onView: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ReportViewPage(report: report),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _statusCounts(List<IssueReport> reports) {
    var reported = 0, progress = 0, resolved = 0;
    for (final r in reports) {
      switch (r.status.trim().toLowerCase()) {
        case 'pending':
          reported++;
          break;
        case 'in_progress':
          progress++;
          break;
        case 'resolved':
          resolved++;
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
      items = items.where((r) {
        final s = r.status.trim().toLowerCase();
        switch (_selectedFilter) {
          case 'reported':
            return s == 'pending';
          case 'progress':
            return s == 'in_progress';
          case 'resolved':
            return s == 'resolved';
        }
        return true;
      }).toList();
    }
    if (query.isNotEmpty) {
      items = items
          .where(
            (r) =>
                r.title.toLowerCase().contains(query) ||
                r.location.address.toLowerCase().contains(query) ||
                r.location.municipality.toLowerCase().contains(query),
          )
          .toList();
    }
    return items;
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
