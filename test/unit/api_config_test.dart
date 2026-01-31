import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/core/api/api_config.dart';

void main() {
  group('ApiConfig', () {
    test(
      'serverUrl defaults to localhost:4000 when no dart-define provided',
      () {
        expect(ApiConfig.serverUrl, 'http://localhost:4000');
      },
    );

    test('uriForPath normalizes slashes', () {
      final u1 = ApiConfig.uriForPath('health');
      expect(u1.toString(), 'http://localhost:4000/health');

      final u2 = ApiConfig.uriForPath('/api/auth/login');
      expect(u2.toString(), 'http://localhost:4000/api/auth/login');
    });
  });
}
