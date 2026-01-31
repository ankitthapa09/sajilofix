import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/password_strength.dart';

void main() {
  group('passwordStrength', () {
    test('returns none for empty/whitespace', () {
      expect(passwordStrength(''), PasswordStrength.none);
      expect(passwordStrength('   '), PasswordStrength.none);
    });

    test('returns weak when only one criterion is met', () {
      // Only lowercase.
      expect(passwordStrength('abcdef'), PasswordStrength.weak);
      // Only uppercase.
      expect(passwordStrength('ABCDEF'), PasswordStrength.weak);
      // Only digits.
      expect(passwordStrength('123456'), PasswordStrength.weak);
    });

    test('returns medium when two criteria are met', () {
      // Lowercase + digits.
      expect(passwordStrength('abc123'), PasswordStrength.medium);
      // Uppercase + long enough.
      expect(passwordStrength('ABCDEFGH'), PasswordStrength.medium);
    });

    test('returns strong when three or four criteria are met', () {
      expect(passwordStrength('Abcdefg1'), PasswordStrength.strong);
      expect(passwordStrength('Abcdefg123'), PasswordStrength.strong);
    });

    test('trims input before scoring', () {
      expect(passwordStrength('   Abcdefg1   '), PasswordStrength.strong);
    });
  });
}
