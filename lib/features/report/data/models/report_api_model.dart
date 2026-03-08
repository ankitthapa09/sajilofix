import 'package:sajilofix/features/report/domain/entities/issue_report.dart';

class IssueLocationApiModel {
  final String address;
  final String district;
  final String municipality;
  final String ward;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  const IssueLocationApiModel({
    required this.address,
    required this.district,
    required this.municipality,
    required this.ward,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  factory IssueLocationApiModel.fromJson(Map<String, dynamic> json) {
    return IssueLocationApiModel(
      address: (json['address'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      municipality: (json['municipality'] ?? '').toString(),
      ward: (json['ward'] ?? '').toString(),
      landmark: json['landmark']?.toString(),
      latitude: _tryParseDouble(json['latitude']),
      longitude: _tryParseDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'address': address,
      'district': district,
      'municipality': municipality,
      'ward': ward,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  IssueLocation toEntity() {
    return IssueLocation(
      address: address,
      district: district,
      municipality: municipality,
      ward: ward,
      landmark: landmark,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static double? _tryParseDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    return parsed;
  }
}

class IssueReportApiModel {
  final String id;
  final String category;
  final String title;
  final String description;
  final String urgency;
  final String status;
  final String? statusUpdatedByRole;
  final DateTime? statusUpdatedAt;
  final IssueLocationApiModel location;
  final List<String> photos;
  final DateTime? createdAt;
  final ReporterInfoApiModel? reporter;

  const IssueReportApiModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.urgency,
    required this.status,
    this.statusUpdatedByRole,
    this.statusUpdatedAt,
    required this.location,
    required this.photos,
    this.createdAt,
    this.reporter,
  });

  factory IssueReportApiModel.fromJson(Map<String, dynamic> json) {
    final reporterMap = ReporterInfoApiModel.extract(json);
    return IssueReportApiModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      urgency: (json['urgency'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      statusUpdatedByRole: _readString(json, [
        'statusUpdatedByRole',
        'status_updated_by_role',
        'updatedByRole',
      ]),
      statusUpdatedAt: _tryParseDateTime(
        json['statusUpdatedAt'] ??
            json['status_updated_at'] ??
            json['statusUpdated'] ??
            json['status_updated'] ??
            json['updatedAt'],
      ),
      location: IssueLocationApiModel.fromJson(
        (json['location'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      photos: _asStringList(json['photos']),
      createdAt: _tryParseDateTime(json['createdAt']),
      reporter: reporterMap == null
          ? null
          : ReporterInfoApiModel.fromJson(reporterMap),
    );
  }

  IssueReport toEntity() {
    return IssueReport(
      id: id,
      category: category,
      title: title,
      description: description,
      urgency: urgency,
      status: status,
      statusUpdatedByRole: statusUpdatedByRole,
      statusUpdatedAt: statusUpdatedAt,
      location: location.toEntity(),
      photos: photos,
      createdAt: createdAt,
      reporter: reporter?.toEntity(),
    );
  }

  static List<String> _asStringList(Object? raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final str = value.toString().trim();
      if (str.isNotEmpty) return str;
    }
    return null;
  }
}

class ReporterInfoApiModel {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? status;
  final String? profilePhoto;

  const ReporterInfoApiModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.status,
    this.profilePhoto,
  });

  factory ReporterInfoApiModel.fromJson(Map<String, dynamic> json) {
    return ReporterInfoApiModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
      profilePhoto: (json['profilePhoto'] ?? json['avatar'] ?? json['photo'])
          ?.toString(),
    );
  }

  ReporterInfo toEntity() {
    return ReporterInfo(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      status: status,
      profilePhoto: profilePhoto,
    );
  }

  static Map<String, dynamic>? extract(Map<String, dynamic> json) {
    final candidates = [
      json['reporter'],
      json['reportedBy'],
      json['createdBy'],
      json['user'],
      json['citizen'],
      json['author'],
      json['owner'],
    ];

    for (final value in candidates) {
      if (value is Map) {
        return value.cast<String, dynamic>();
      }
    }

    final reporterId = json['reporterId'] ?? json['reporter_id'];
    final reporterName = json['reporterName'] ?? json['reporter_name'];
    final reporterPhoto = json['reporterPhoto'] ?? json['reporter_photo'];
    if (reporterId != null || reporterName != null || reporterPhoto != null) {
      return <String, dynamic>{
        '_id': reporterId,
        'id': reporterId,
        'fullName': reporterName ?? '',
        'profilePhoto': reporterPhoto,
      };
    }

    return null;
  }
}
