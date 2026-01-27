import 'package:flutter/foundation.dart';

@immutable
class ReportFormDraft {
  final String? category;
  final String? locationTitle;
  final String? locationSubtitle;
  final String? landmark;
  final String? issueTitle;
  final String? issueDescription;
  final String? urgency;

  const ReportFormDraft({
    this.category,
    this.locationTitle,
    this.locationSubtitle,
    this.landmark,
    this.issueTitle,
    this.issueDescription,
    this.urgency,
  });

  ReportFormDraft copyWith({
    String? category,
    String? locationTitle,
    String? locationSubtitle,
    String? landmark,
    String? issueTitle,
    String? issueDescription,
    String? urgency,
  }) {
    return ReportFormDraft(
      category: category ?? this.category,
      locationTitle: locationTitle ?? this.locationTitle,
      locationSubtitle: locationSubtitle ?? this.locationSubtitle,
      landmark: landmark ?? this.landmark,
      issueTitle: issueTitle ?? this.issueTitle,
      issueDescription: issueDescription ?? this.issueDescription,
      urgency: urgency ?? this.urgency,
    );
  }
}
