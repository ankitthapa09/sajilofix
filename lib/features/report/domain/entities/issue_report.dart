import 'package:image_picker/image_picker.dart';

class IssueLocation {
  final String address;
  final String district;
  final String municipality;
  final String ward;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  const IssueLocation({
    required this.address,
    required this.district,
    required this.municipality,
    required this.ward,
    this.landmark,
    this.latitude,
    this.longitude,
  });
}

class IssueReport {
  final String id;
  final String category;
  final String title;
  final String description;
  final String urgency;
  final String status;
  final IssueLocation location;
  final List<String> photos;
  final DateTime? createdAt;

  const IssueReport({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.urgency,
    required this.status,
    required this.location,
    required this.photos,
    this.createdAt,
  });
}

class CreateIssueReportInput {
  final String category;
  final String title;
  final String description;
  final String urgency;
  final IssueLocation location;
  final List<XFile> photos;

  const CreateIssueReportInput({
    required this.category,
    required this.title,
    required this.description,
    required this.urgency,
    required this.location,
    required this.photos,
  });
}
