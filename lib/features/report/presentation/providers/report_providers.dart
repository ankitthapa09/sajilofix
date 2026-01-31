import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/presentation/models/report_form_draft.dart';

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
  }) {
    state = state.copyWith(
      locationTitle: title,
      locationSubtitle: subtitle,
      landmark: landmark,
    );
  }

  void setIssueDetails({required String title, required String description}) {
    state = state.copyWith(issueTitle: title, issueDescription: description);
  }

  void setUrgency(String urgency) {
    state = state.copyWith(urgency: urgency);
  }
}
