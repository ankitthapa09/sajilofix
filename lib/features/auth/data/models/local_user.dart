import 'package:hive/hive.dart';

part 'local_user.g.dart';

@HiveType(typeId: 1)
class LocalUser extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final int roleIndex;

  @HiveField(4)
  final String passwordHash;

  @HiveField(5)
  final String? dob;

  @HiveField(6)
  final String? citizenshipNumber;

  @HiveField(7)
  final String? district;

  @HiveField(8)
  final String? municipality;

  @HiveField(9)
  final String? ward;

  @HiveField(10)
  final String? tole;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final String? profilePhoto;

  LocalUser({
    required this.email,
    required this.fullName,
    required this.phone,
    required this.roleIndex,
    required this.passwordHash,
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
