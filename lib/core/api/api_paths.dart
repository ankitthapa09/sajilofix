/// Backend API route paths.
///
/// Keep this file free of environment-specific base URLs.
/// Base URL/config will be added separately (mobile vs web).
class ApiPaths {
  ApiPaths._();

  static const String health = '/health';

  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
}
