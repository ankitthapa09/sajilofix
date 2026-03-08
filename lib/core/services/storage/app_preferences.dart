import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _biometricEnabledPrefix = 'biometric_enabled_role_';

  static Future<bool> isBiometricEnabled({required int roleIndex}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_biometricEnabledPrefix$roleIndex') ?? false;
  }

  static Future<void> setBiometricEnabled({
    required int roleIndex,
    required bool enabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_biometricEnabledPrefix$roleIndex', enabled);
  }
}
