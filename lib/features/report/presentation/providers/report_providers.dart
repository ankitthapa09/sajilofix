import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajilofix/core/api/api_client.dart';
import 'package:sajilofix/features/report/presentation/models/report_form_draft.dart';
import 'package:sajilofix/core/services/network/network_info.dart';
import 'package:sajilofix/features/report/data/datasources/remote/report_remote_datasource.dart';
import 'package:sajilofix/features/report/data/repositories/report_repository_impl.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/domain/repositories/report_repository.dart';
import 'package:sajilofix/features/report/domain/usecases/submit_report_usecase.dart';

final reportFormDraftProvider =
    StateNotifierProvider<ReportFormDraftNotifier, ReportFormDraft>((ref) {
      return ReportFormDraftNotifier();
    });

class ReportFormDraftNotifier extends StateNotifier<ReportFormDraft> {
  ReportFormDraftNotifier() : super(const ReportFormDraft());

  void reset() {
    state = const ReportFormDraft();
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setLocation({
    required String title,
    required String subtitle,
    String? landmark,
    String? district,
    String? ward,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      locationTitle: title,
      locationSubtitle: subtitle,
      landmark: landmark,
      district: district,
      ward: ward,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void setIssueDetails({required String title, required String description}) {
    state = state.copyWith(issueTitle: title, issueDescription: description);
  }

  void setUrgency(String urgency) {
    state = state.copyWith(urgency: urgency);
  }

  void setPhotos(List<XFile> photos) {
    state = state.copyWith(photos: List<XFile>.from(photos));
  }

  void addPhoto(XFile photo) {
    state = state.copyWith(photos: [...state.photos, photo]);
  }

  void removePhotoAt(int index) {
    final updated = List<XFile>.from(state.photos);
    if (index < 0 || index >= updated.length) return;
    updated.removeAt(index);
    state = state.copyWith(photos: updated);
  }
}

final reportRemoteDatasourceProvider = Provider<ReportRemoteDatasource>((ref) {
  return ReportRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    remote: ref.read(reportRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final submitReportUseCaseProvider = Provider<SubmitReportUseCase>((ref) {
  return SubmitReportUseCase(ref.read(reportRepositoryProvider));
});

final myReportsProvider = FutureProvider<List<IssueReport>>((ref) async {
  return ref.read(reportRepositoryProvider).listMyReports();
});

final adminIssuesControllerProvider =
    StateNotifierProvider<AdminIssuesController, AsyncValue<List<IssueReport>>>(
      (ref) => AdminIssuesController(ref.read(reportRepositoryProvider)),
    );

class AdminIssuesController
    extends StateNotifier<AsyncValue<List<IssueReport>>> {
  final ReportRepository _repository;

  AdminIssuesController(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.listAllReports);
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> deleteIssue(String id) async {
    await _repository.deleteIssue(id);
    final current = state.valueOrNull ?? const <IssueReport>[];
    state = AsyncValue.data(current.where((issue) => issue.id != id).toList());
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
                    location: issue.location,
                    photos: issue.photos,
                    createdAt: issue.createdAt,
                  )
                : issue,
          )
          .toList(),
    );
  }
}
