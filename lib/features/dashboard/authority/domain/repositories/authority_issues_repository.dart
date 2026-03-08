import 'package:sajilofix/features/report/domain/entities/issue_report.dart';

abstract class AuthorityIssuesRepository {
  Future<List<IssueReport>> listAllIssues();

  Future<String> updateIssueStatus({
    required String id,
    required String status,
  });
}
