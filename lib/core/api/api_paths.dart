// Backend API route paths.

/// Base URL/config will be added separately (mobile vs web).
class ApiPaths {
  ApiPaths._();

  static const String health = '/health';

  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';

  // Profile
  static const String uploadProfilePhoto = '/api/users/me/photo';
  static const String getMe = '/api/users/me';
  static const String updateMe = '/api/users/me';
  static const String deleteProfilePhoto = '/api/users/me/photo';

  // Issues
  static const String issues = '/api/issues';
  static const String issueById = '/api/issues/';
  static const String issueReverseGeocode = '/api/issues/reverse-geocode';
  static const String issueSearchLocation = '/api/issues/search-location';

  // Admin
  static const String adminUsers = '/api/admin/users';
  static const String adminAuthorities = '/api/admin/authorities';
  static const String adminAuthorityById = '/api/admin/authorities/';
  static const String adminCitizens = '/api/admin/citizens';
  static const String adminCitizenById = '/api/admin/citizens/';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String notificationsUnreadCount =
      '/api/notifications/unread-count';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static const String notificationById = '/api/notifications/';
}
