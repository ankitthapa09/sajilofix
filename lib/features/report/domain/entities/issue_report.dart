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
  final String? statusUpdatedByRole;
  final DateTime? statusUpdatedAt;
  final List<IssueStatusHistoryEntry> statusHistory;
  final IssueLocation location;
  final List<String> photos;
  final DateTime? createdAt;
  final ReporterInfo? reporter;

  const IssueReport({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.urgency,
    required this.status,
    this.statusUpdatedByRole,
    this.statusUpdatedAt,
    this.statusHistory = const [],
    required this.location,
    required this.photos,
    this.createdAt,
    this.reporter,
  });
}

class IssueStatusHistoryEntry {
  final String status;
  final String changedByRole;
  final String? changedByUserId;
  final DateTime? changedAt;

  const IssueStatusHistoryEntry({
    required this.status,
    required this.changedByRole,
    this.changedByUserId,
    this.changedAt,
  });
}

class ReporterInfo {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? status;
  final String? profilePhoto;

  const ReporterInfo({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.status,
    this.profilePhoto,
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
