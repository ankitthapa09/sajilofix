import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/password_strength.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/password_strength_meter.dart';

void main() {
  testWidgets('PasswordStrengthMeter hides label when strength is none', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PasswordStrengthMeter(strength: PasswordStrength.none),
        ),
      ),
    );

    expect(find.text('Password strength:'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('PasswordStrengthMeter shows label and strength text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PasswordStrengthMeter(strength: PasswordStrength.strong),
        ),
      ),
    );

    expect(find.text('Password strength:'), findsOneWidget);
    expect(find.text('Strong'), findsOneWidget);
  });
}
