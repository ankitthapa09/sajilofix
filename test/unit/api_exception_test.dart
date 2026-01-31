import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/core/api/api_exception.dart';

void main() {
  group('ApiException.fromResponse', () {
    test('uses message key when present', () {
      final ex = ApiException.fromResponse(
        statusCode: 400,
        data: {'message': 'Bad Request'},
      );
      expect(ex.message, 'Bad Request');
      expect(ex.statusCode, 400);
    });

    test('falls back to error/errors keys when message missing', () {
      final ex1 = ApiException.fromResponse(
        statusCode: 500,
        data: {'error': 'Oops'},
      );
      expect(ex1.message, 'Oops');

      final ex2 = ApiException.fromResponse(
        statusCode: 500,
        data: {'errors': 'Many oops'},
      );
      expect(ex2.message, 'Many oops');
    });

    test('extracts message from string payload', () {
      final ex = ApiException.fromResponse(statusCode: 404, data: 'Not Found');
      expect(ex.message, 'Not Found');
    });

    test('uses default message when it cannot extract', () {
      final ex = ApiException.fromResponse(statusCode: 418, data: 123);
      expect(ex.message, 'Request failed');
    });
  });

  group('ApiException.fromError', () {
    test('uses toString() for client-side errors', () {
      final ex = ApiException.fromError(StateError('boom'));
      expect(ex.message, contains('boom'));
    });
  });
}
