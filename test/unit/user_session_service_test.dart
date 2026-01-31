import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilofix/core/services/storage/user_session_service.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    await UserSessionService.clear();
  });

  test('starts logged out by default', () {
    expect(UserSessionService.currentUserEmail, isNull);
    expect(UserSessionService.isLoggedIn, isFalse);
  });

  test('setCurrentUserEmail sets email and isLoggedIn', () async {
    await UserSessionService.setCurrentUserEmail('user@example.com');
    expect(UserSessionService.currentUserEmail, 'user@example.com');
    expect(UserSessionService.isLoggedIn, isTrue);
  });

  test('clear removes email and resets isLoggedIn', () async {
    await UserSessionService.setCurrentUserEmail('user@example.com');
    await UserSessionService.clear();

    expect(UserSessionService.currentUserEmail, isNull);
    expect(UserSessionService.isLoggedIn, isFalse);
  });
}
