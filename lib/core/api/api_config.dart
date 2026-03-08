import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // Example: --dart-define=SAJILOFIX_API_BASE_URL=http://192.168.1.10:4000
  static const String _definedBaseUrl = String.fromEnvironment(
    'SAJILOFIX_API_BASE_URL',
    defaultValue: '',
  );

  // Host override (useful for physical devices).
  // Example: --dart-define=SAJILOFIX_API_HOST=192.168.1.10
  static const String _definedHost = String.fromEnvironment(
    'SAJILOFIX_API_HOST',
    defaultValue: '192.168.0.105',
  );

  // Port override.
  // Example: --dart-define=SAJILOFIX_API_PORT=4000
  static const int _definedPort = int.fromEnvironment(
    'SAJILOFIX_API_PORT',
    defaultValue: 4000,
  );

  // Example: --dart-define=SAJILOFIX_IS_PHYSICAL_DEVICE=true
  static const bool isPhysicalDevice = bool.fromEnvironment(
    'SAJILOFIX_IS_PHYSICAL_DEVICE',
    defaultValue: true,
  );

  // Fallback IP for physical device if you didn't pass SAJILOFIX_API_HOST.
  static const String _fallbackIpAddress = String.fromEnvironment(
    'SAJILOFIX_FALLBACK_IP',
    defaultValue: '192.168.0.105',
  );

  static int get port => _definedPort;

  // Base host chosen automatically by platform.
  static String get _host {
    if (_definedHost.trim().isNotEmpty) return _definedHost.trim();

    if (isPhysicalDevice) {
      return _fallbackIpAddress.trim().isEmpty
          ? 'localhost'
          : _fallbackIpAddress.trim();
    }

    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) {
      // If fallback IP is provided, prefer it so physical-device runs work
      // without requiring SAJILOFIX_IS_PHYSICAL_DEVICE=true.
      if (_fallbackIpAddress.trim().isNotEmpty)
        return _fallbackIpAddress.trim();
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static String get serverUrl {
    if (_definedBaseUrl.trim().isNotEmpty) {
      return _definedBaseUrl.trim().replaceAll(RegExp(r'/$'), '');
    }
    return 'http://$_host:$port';
  }

  static String get baseUrl => serverUrl;

  static Uri uriForPath(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
