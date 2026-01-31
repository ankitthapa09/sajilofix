import 'package:sajilofix/features/auth/data/models/local_user.dart';
import 'package:sajilofix/features/auth/domain/entities/auth_user.dart';

extension LocalUserMapper on LocalUser {
  AuthUser toEntity() {
    return AuthUser(
      email: email,
      fullName: fullName,
      phone: phone,
      roleIndex: roleIndex,
      profilePhoto: profilePhoto,
      dob: dob,
      citizenshipNumber: citizenshipNumber,
      district: district,
      municipality: municipality,
      ward: ward,
      tole: tole,
      createdAt: createdAt,
    );
  }
}
