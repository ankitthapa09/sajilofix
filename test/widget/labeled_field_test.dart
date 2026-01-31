import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/labeled_field.dart';

void main() {
  testWidgets('LabeledField shows label and child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LabeledField(label: 'Email', child: TextField()),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
