import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/section_card.dart';

void main() {
  testWidgets('SectionCard shows leading icon, title, and child', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionCard(
            title: 'Profile',
            leading: Icons.person,
            child: Text('Inner content'),
          ),
        ),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Inner content'), findsOneWidget);
  });
}
