class AuthUser {
  final String email;
  final String fullName;
  final String phone;
  final int roleIndex;

  final String? profilePhoto;

  final String? dob;
  final String? citizenshipNumber;
  final String? district;
  final String? municipality;
  final String? ward;
  final String? tole;

  final DateTime createdAt;

  const AuthUser({
    required this.email,
    required this.fullName,
    required this.phone,
    required this.roleIndex,
    required this.createdAt,
    this.profilePhoto,
    this.dob,
    this.citizenshipNumber,
    this.district,
    this.municipality,
    this.ward,
    this.tole,
  });
}
