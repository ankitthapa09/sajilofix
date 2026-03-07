import 'package:sajilofix/features/report/domain/entities/issue_report.dart';

abstract interface class ReportRepository {
  Future<IssueReport> submitReport(CreateIssueReportInput input);
  Future<List<IssueReport>> listReports();
  Future<void> deleteIssue(String id);
}
