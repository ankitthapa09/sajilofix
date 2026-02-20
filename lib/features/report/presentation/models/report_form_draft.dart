import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

@immutable
class ReportFormDraft {
  final String? category;
  final String? locationTitle;
  final String? locationSubtitle;
  final String? landmark;
  final String? district;
  final String? ward;
  final double? latitude;
  final double? longitude;
  final String? issueTitle;
  final String? issueDescription;
  final String? urgency;
  final List<XFile> photos;

  const ReportFormDraft({
    this.category,
    this.locationTitle,
    this.locationSubtitle,
    this.landmark,
    this.district,
    this.ward,
    this.latitude,
    this.longitude,
    this.issueTitle,
    this.issueDescription,
    this.urgency,
    this.photos = const [],
  });

  ReportFormDraft copyWith({
    String? category,
    String? locationTitle,
    String? locationSubtitle,
    String? landmark,
    String? district,
    String? ward,
    double? latitude,
    double? longitude,
    String? issueTitle,
    String? issueDescription,
    String? urgency,
    List<XFile>? photos,
  }) {
    return ReportFormDraft(
      category: category ?? this.category,
      locationTitle: locationTitle ?? this.locationTitle,
      locationSubtitle: locationSubtitle ?? this.locationSubtitle,
      landmark: landmark ?? this.landmark,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      issueTitle: issueTitle ?? this.issueTitle,
      issueDescription: issueDescription ?? this.issueDescription,
      urgency: urgency ?? this.urgency,
      photos: photos ?? List<XFile>.from(this.photos),
    );
  }
}
