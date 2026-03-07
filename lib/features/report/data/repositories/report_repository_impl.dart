import 'package:sajilofix/core/api/api_exception.dart';
import 'package:sajilofix/core/services/network/network_info.dart';
import 'package:sajilofix/features/report/data/datasources/remote/report_remote_datasource.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDatasource _remote;
  final INetworkInfo _networkInfo;

  const ReportRepositoryImpl({
    required ReportRemoteDatasource remote,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _networkInfo = networkInfo;

  @override
  Future<IssueReport> submitReport(CreateIssueReportInput input) async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.createIssueReport(input);
  }

  @override
  Future<List<IssueReport>> listReports() async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.listIssues();
  }

  @override
  Future<List<IssueReport>> listMyReports() async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.listIssues();
  }

  @override
  Future<List<IssueReport>> listAllReports() async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.listIssues(scope: 'all');
  }

  @override
  Future<void> deleteIssue(String id) async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    await _remote.deleteIssue(id);
  }

  @override
  Future<String> updateIssueStatus({
    required String id,
    required String status,
  }) async {
    final online = await _safeOnlineCheck();
    if (!online) {
      throw ApiException.fromError('No internet connection');
    }

    return _remote.updateIssueStatus(id: id, status: status);
  }

  Future<bool> _safeOnlineCheck() async {
    try {
      return await _networkInfo.isConnected;
    } catch (_) {
      return false;
    }
  }
}
