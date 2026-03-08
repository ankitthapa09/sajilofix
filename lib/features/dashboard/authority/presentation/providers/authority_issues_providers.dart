import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/dashboard/authority/data/authority_issues_repository_impl.dart';
import 'package:sajilofix/features/dashboard/authority/domain/repositories/authority_issues_repository.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

final authorityIssuesRepositoryProvider = Provider<AuthorityIssuesRepository>(
  (ref) => AuthorityIssuesRepositoryImpl(ref.read(reportRepositoryProvider)),
);

final authorityIssuesControllerProvider =
    StateNotifierProvider<
      AuthorityIssuesController,
      AsyncValue<List<IssueReport>>
    >(
      (ref) => AuthorityIssuesController(
        ref.read(authorityIssuesRepositoryProvider),
      ),
    );

class AuthorityIssuesController
    extends StateNotifier<AsyncValue<List<IssueReport>>> {
  final AuthorityIssuesRepository _repository;

  AuthorityIssuesController(this._repository)
    : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.listAllIssues);
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> updateIssueStatus({
    required String id,
    required String status,
  }) async {
    final updatedStatus = await _repository.updateIssueStatus(
      id: id,
      status: status,
    );
    final current = state.valueOrNull ?? const <IssueReport>[];
    state = AsyncValue.data(
      current
          .map(
            (issue) => issue.id == id
                ? IssueReport(
                    id: issue.id,
                    category: issue.category,
                    title: issue.title,
                    description: issue.description,
                    urgency: issue.urgency,
                    status: updatedStatus,
                    statusUpdatedByRole: issue.statusUpdatedByRole,
                    statusUpdatedAt: issue.statusUpdatedAt,
                    location: issue.location,
                    photos: issue.photos,
                    createdAt: issue.createdAt,
                    reporter: issue.reporter,
                  )
                : issue,
          )
          .toList(),
    );
  }
}
