import 'package:sajilofix/core/constants/hive_constants.dart';
import 'package:sajilofix/core/services/hive/hive_service.dart';

class UserSessionService {
  UserSessionService._();

  static String? get currentUserEmail {
    return HiveService.sessionBox().get(HiveSessionKeys.currentUserEmail)
        as String?;
  }

  static bool get isLoggedIn => (currentUserEmail ?? '').isNotEmpty;

  static Future<void> setCurrentUserEmail(String email) async {
    await HiveService.sessionBox().put(HiveSessionKeys.currentUserEmail, email);
  }

  static Future<void> clear() async {
    await HiveService.sessionBox().delete(HiveSessionKeys.currentUserEmail);
  }
}
