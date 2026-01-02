import 'package:sajilofix/core/constants/session_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  UserSessionService._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  static String? get currentUserEmail {
    return _prefs?.getString(SessionKeys.currentUserEmail);
  }

  static bool get isLoggedIn => (currentUserEmail ?? '').isNotEmpty;

  static Future<void> setCurrentUserEmail(String email) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(SessionKeys.currentUserEmail, email);
  }

  static Future<void> clear() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(SessionKeys.currentUserEmail);
  }
}
