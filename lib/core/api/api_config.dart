class ApiConfig {
  ApiConfig._();

  // For mobile development, base URLs differ by device:
  // - Android emulator: http://10.0.2.2:4000
  // - iOS simulator:    http://localhost:5000
  // - For Physical Device use your computer's IP: 'http://192.168.x.x:5000'
  // - ApiConfig owns the environment base URL (via --dart-define).
  static const String baseUrl = String.fromEnvironment(
    'SAJILOFIX_API_BASE_URL',
    defaultValue: 'http://172.26.18.142:4000',
  );

  static Uri uriForPath(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
