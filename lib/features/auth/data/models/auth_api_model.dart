import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? password;
  final int roleIndex;

  final String? profilePhoto;

  final String? dob;
  final String? citizenshipNumber;
  final String? district;
  final String? municipality;
  final String? ward;
  final String? tole;

  final DateTime? createdAt;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.password,
    required this.roleIndex,
    this.profilePhoto,
    this.dob,
    this.citizenshipNumber,
    this.district,
    this.municipality,
    this.ward,
    this.tole,
    this.createdAt,
  });

  // toJSON
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,

      // Optional profile fields
      'dob': dob,
      'citizenshipNumber': citizenshipNumber,
      'district': district,
      'municipality': municipality,
      'ward': ward,
      'tole': tole,

      // role is derived by backend; roleIndex client-side only.
    };
  }

  // FromJSON
  factory AuthApiModel.fromJSON(Map<String, dynamic> json) {
    final email = (json['email'] ?? '').toString();

    return AuthApiModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      fullName: (json['fullName'] ?? json['name'] ?? '').toString(),
      email: email,
      phone: (json['phone'] ?? json['phoneNumber'])?.toString(),
      roleIndex: _parseRoleIndex(json, email: email),
      profilePhoto: json['profilePhoto']?.toString(),
      dob: json['dob']?.toString(),
      citizenshipNumber: json['citizenshipNumber']?.toString(),
      district: json['district']?.toString(),
      municipality: json['municipality']?.toString(),
      ward: (json['ward'] ?? json['wardNumber'])?.toString(),
      tole: json['tole']?.toString(),
      createdAt: _tryParseDateTime(json['createdAt']),
    );
  }

  // toEntity
  AuthUser toEntity() {
    return AuthUser(
      email: email,
      fullName: fullName,
      phone: phone ?? '',
      roleIndex: roleIndex,
      profilePhoto: _nullIfBlank(profilePhoto),
      dob: _nullIfBlank(dob),
      citizenshipNumber: _nullIfBlank(citizenshipNumber),
      district: _nullIfBlank(district),
      municipality: _nullIfBlank(municipality),
      ward: _nullIfBlank(ward),
      tole: _nullIfBlank(tole),
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  // fromEntity
  factory AuthApiModel.fromEntity(AuthUser entity, {String? password}) {
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      password: password,
      roleIndex: entity.roleIndex,
      profilePhoto: entity.profilePhoto,
      dob: entity.dob,
      citizenshipNumber: entity.citizenshipNumber,
      district: entity.district,
      municipality: entity.municipality,
      ward: entity.ward,
      tole: entity.tole,
      createdAt: entity.createdAt,
    );
  }

  // toEntityList
  static List<AuthUser> toEnityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  static int _parseRoleIndex(
    Map<String, dynamic> json, {
    required String email,
  }) {
    final roleIndex = json['roleIndex'];
    if (roleIndex is int) return roleIndex;

    if (roleIndex is String) {
      final parsed = int.tryParse(roleIndex.trim());
      if (parsed != null) return parsed;
    }

    // If backend sends role as a string.
    final role = (json['role'] ?? '').toString().trim().toLowerCase();
    if (role.isNotEmpty) {
      switch (role) {
        case 'citizen':
          return 0;
        case 'admin':
          return 1;
        case 'authority':
          return 2;
      }
    }

    // Fallback: derive from email (matches backend intent).
    final normalized = email.trim().toLowerCase();
    if (normalized == 'admin@sajilofix.com') return 1;
    if (normalized.endsWith('@sajilofix.gov.np')) return 2;
    return 0;
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  static String? _nullIfBlank(String? value) {
    final v = (value ?? '').trim();
    return v.isEmpty ? null : v;
  }
}
