class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? data;

  const ApiException({required this.message, this.statusCode, this.data});

  // Builds an ApiException from an HTTP response payload.
  // Sajilofix backend uses a consistent shape: `{ "message": "..." }`.
  factory ApiException.fromResponse({required int statusCode, Object? data}) {
    final message = _extractMessage(data) ?? 'Request failed';
    return ApiException(message: message, statusCode: statusCode, data: data);
  }

  // Fallback for client-side errors (timeouts, parsing errors, etc).
  factory ApiException.fromError(Object error) {
    final message = error.toString();
    return ApiException(message: message);
  }

  static String? _extractMessage(Object? data) {
    if (data == null) return null;

    if (data is Map) {
      final value = data['message'];
      if (value is String && value.trim().isNotEmpty) return value.trim();

      // Some backends use different keys.
      final alt = data['error'] ?? data['errors'];
      if (alt is String && alt.trim().isNotEmpty) return alt.trim();
    }

    if (data is String) {
      final v = data.trim();
      return v.isEmpty ? null : v;
    }

    return null;
  }

  @override
  String toString() => message;
}
