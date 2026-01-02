import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:sajilofix/core/services/hive/hive_service.dart';
import 'package:sajilofix/features/auth/data/models/local_user.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource();

  String _passwordHash({required String email, required String password}) {
    // Not meant as production security—just avoids plain-text storage.
    final bytes = utf8.encode('$email::$password');
    return sha256.convert(bytes).toString();
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String phone,
    required int roleIndex,
    required String password,
    String? dob,
    String? citizenshipNumber,
    String? district,
    String? municipality,
    String? ward,
    String? tole,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final box = HiveService.usersBox();
    final existing = box.get(normalizedEmail);
    if (existing != null) {
      throw const AuthLocalException('User already exists with this email');
    }

    final user = LocalUser(
      email: normalizedEmail,
      fullName: fullName.trim(),
      phone: phone.trim(),
      roleIndex: roleIndex,
      passwordHash: _passwordHash(email: normalizedEmail, password: password),
      dob: (dob ?? '').trim().isEmpty ? null : dob?.trim(),
      citizenshipNumber: (citizenshipNumber ?? '').trim().isEmpty
          ? null
          : citizenshipNumber?.trim(),
      district: (district ?? '').trim().isEmpty ? null : district?.trim(),
      municipality: (municipality ?? '').trim().isEmpty
          ? null
          : municipality?.trim(),
      ward: (ward ?? '').trim().isEmpty ? null : ward?.trim(),
      tole: (tole ?? '').trim().isEmpty ? null : tole?.trim(),
      createdAt: DateTime.now(),
    );

    await box.put(normalizedEmail, user);
  }

  Future<LocalUser> login({
    required String email,
    required String password,
    required int roleIndex,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final user = HiveService.usersBox().get(normalizedEmail);
    if (user == null) {
      throw const AuthLocalException('No user found for this email');
    }

    final expectedHash = _passwordHash(
      email: normalizedEmail,
      password: password,
    );
    if (user.passwordHash != expectedHash) {
      throw const AuthLocalException('Incorrect password');
    }

    if (user.roleIndex != roleIndex) {
      throw const AuthLocalException('Role does not match this account');
    }

    return user;
  }

  Future<LocalUser?> getUserByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    return HiveService.usersBox().get(normalizedEmail);
  }
}

class AuthLocalException implements Exception {
  final String message;
  const AuthLocalException(this.message);

  @override
  String toString() => message;
}
