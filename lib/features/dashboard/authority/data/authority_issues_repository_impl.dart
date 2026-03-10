import 'package:sajilofix/features/dashboard/authority/domain/repositories/authority_issues_repository.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/domain/repositories/report_repository.dart';

class AuthorityIssuesRepositoryImpl implements AuthorityIssuesRepository {
  final ReportRepository _reportRepository;

  AuthorityIssuesRepositoryImpl(this._reportRepository);

  @override
  Future<List<IssueReport>> listAllIssues() {
    return _reportRepository.listAllReports();
  }

  @override
  Future<String> updateIssueStatus({
    required String id,
    required String status,
  }) {
    return _reportRepository.updateIssueStatus(id: id, status: status);
  }
}
