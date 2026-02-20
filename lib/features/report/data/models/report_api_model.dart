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
  final IssueLocationApiModel location;
  final List<String> photos;
  final DateTime? createdAt;

  const IssueReportApiModel({
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

  factory IssueReportApiModel.fromJson(Map<String, dynamic> json) {
    return IssueReportApiModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      urgency: (json['urgency'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      location: IssueLocationApiModel.fromJson(
        (json['location'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      photos: _asStringList(json['photos']),
      createdAt: _tryParseDateTime(json['createdAt']),
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
      location: location.toEntity(),
      photos: photos,
      createdAt: createdAt,
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
}
