import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/domain/repositories/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository _repository;

  const SubmitReportUseCase(this._repository);

  Future<IssueReport> call(CreateIssueReportInput input) {
    return _repository.submitReport(input);
  }
}
