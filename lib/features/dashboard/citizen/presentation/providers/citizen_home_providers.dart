import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

class CitizenHomeStats {
  final int total;
  final int resolved;
  final int pending;

  const CitizenHomeStats({
    required this.total,
    required this.resolved,
    required this.pending,
  });

  factory CitizenHomeStats.fromReports(List<IssueReport> reports) {
    var resolved = 0;
    var pending = 0;
    for (final report in reports) {
      final status = report.status.trim().toLowerCase();
      if (status == 'resolved') resolved++;
      if (status == 'pending' || status == 'in_progress') pending++;
    }
    return CitizenHomeStats(
      total: reports.length,
      resolved: resolved,
      pending: pending,
    );
  }
}

final citizenHomeStatsProvider = Provider<AsyncValue<CitizenHomeStats>>((ref) {
  final reportsAsync = ref.watch(myReportsProvider);
  return reportsAsync.whenData(CitizenHomeStats.fromReports);
});
