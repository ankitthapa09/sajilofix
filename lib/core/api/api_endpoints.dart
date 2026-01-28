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
}
