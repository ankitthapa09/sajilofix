import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/signup_step_scaffold.dart';

void main() {
  testWidgets('SignupStepScaffold renders header and wraps child', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SignupStepScaffold(
            icon: Icons.lock,
            title: 'Create account',
            subtitle: 'Fill details',
            child: Text('Form body'),
          ),
        ),
      ),
    );

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Fill details'), findsOneWidget);
    expect(find.text('Form body'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}
