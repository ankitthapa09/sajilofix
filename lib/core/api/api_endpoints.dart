import 'package:sajilofix/core/api/api_config.dart';
import 'package:sajilofix/core/api/api_paths.dart';

/// - `ApiPaths` owns the raw route strings.
/// - `ApiEndpoints` exposes a single place for client code to read base URL,
///   timeouts, and endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => ApiConfig.baseUrl;

  static const Duration connectionTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Endpoints
  static const String health = ApiPaths.health;
  static const String authRegister = ApiPaths.authRegister;
  static const String authLogin = ApiPaths.authLogin;
}
