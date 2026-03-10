import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _biometricEnabledPrefix = 'biometric_enabled_role_';
  static const String _autoDarkModeKey = 'auto_dark_mode_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';

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

  static Future<bool> isAutoDarkModeEnabled() async {
    return isDarkModeEnabled();
  }

  static Future<void> setAutoDarkModeEnabled(bool enabled) async {
    await setDarkModeEnabled(enabled);
  }

  static Future<bool> isDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep backward compatibility with previously persisted key.
    return prefs.getBool(_darkModeKey) ??
        prefs.getBool(_autoDarkModeKey) ??
        false;
  }

  static Future<void> setDarkModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
    await prefs.setBool(_autoDarkModeKey, enabled);
  }
}
