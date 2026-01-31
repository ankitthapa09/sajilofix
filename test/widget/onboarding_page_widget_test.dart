import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/core/widgets/onboarding_page_widget.dart';

void main() {
  testWidgets('OnboardingPageWidget shows icon, title and description', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OnboardingPageWidget(
            icon: Icons.handyman,
            iconColor: Colors.white,
            backgroundColor: Colors.black,
            title: 'Welcome',
            description: 'Fix problems quickly',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.handyman), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Fix problems quickly'), findsOneWidget);
  });
}
