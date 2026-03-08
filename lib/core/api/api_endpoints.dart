import 'package:sajilofix/core/api/api_config.dart';
import 'package:sajilofix/core/api/api_paths.dart';

// - `ApiPaths` owns the raw route strings.
// - `ApiEndpoints` exposes a single place for client code to read base URL,
//   timeouts, and endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  // Root server URL (host + port). Auto-selected by platform.
  // Override via `--dart-define=SAJILOFIX_API_BASE_URL=...` or `SAJILOFIX_API_HOST`.
  static String get baseUrl => ApiConfig.baseUrl;

  static const Duration connectionTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Endpoints
  static const String health = ApiPaths.health;
  static const String authRegister = ApiPaths.authRegister;
  static const String authLogin = ApiPaths.authLogin;

  static const String uploadProfilePhoto = ApiPaths.uploadProfilePhoto;
  static const String getMe = ApiPaths.getMe;
  static const String updateMe = ApiPaths.updateMe;
  static const String deleteProfilePhoto = ApiPaths.deleteProfilePhoto;

  // Issues
  static const String issues = ApiPaths.issues;
  static const String issueById = ApiPaths.issueById;
  static const String issueReverseGeocode = ApiPaths.issueReverseGeocode;
  static const String issueSearchLocation = ApiPaths.issueSearchLocation;

  // Admin
  static const String adminUsers = ApiPaths.adminUsers;
  static const String adminAuthorities = ApiPaths.adminAuthorities;
  static const String adminAuthorityById = ApiPaths.adminAuthorityById;
  static const String adminCitizens = ApiPaths.adminCitizens;
  static const String adminCitizenById = ApiPaths.adminCitizenById;

  // Notifications
  static const String notifications = ApiPaths.notifications;
  static const String notificationsUnreadCount =
      ApiPaths.notificationsUnreadCount;
  static const String notificationsReadAll = ApiPaths.notificationsReadAll;
  static const String notificationById = ApiPaths.notificationById;
}
