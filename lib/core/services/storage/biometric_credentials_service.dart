import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricCredentials {
  final String email;
  final String password;
  final int roleIndex;

  const BiometricCredentials({
    required this.email,
    required this.password,
    required this.roleIndex,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'roleIndex': roleIndex,
    };
  }

  static BiometricCredentials? fromJson(Map<String, dynamic> json) {
    final email = (json['email'] ?? '').toString().trim();
    final password = (json['password'] ?? '').toString();
    final roleIndex = int.tryParse((json['roleIndex'] ?? '').toString());

    if (email.isEmpty || password.isEmpty || roleIndex == null) {
      return null;
    }

    return BiometricCredentials(
      email: email,
      password: password,
      roleIndex: roleIndex,
    );
  }
}

class BiometricCredentialsService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _key = 'biometric_login_credentials';

  static Future<void> save({
    required String email,
    required String password,
    required int roleIndex,
  }) async {
    final payload = BiometricCredentials(
      email: email.trim(),
      password: password,
      roleIndex: roleIndex,
    ).toJson();

    await _storage.write(key: _key, value: jsonEncode(payload));
  }

  static Future<BiometricCredentials?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return BiometricCredentials.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
