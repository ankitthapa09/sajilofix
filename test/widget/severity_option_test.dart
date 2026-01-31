import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilofix/core/widgets/severity_option.dart';

void main() {
  testWidgets('SeverityOption renders label and triggers onTap', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeverityOption(
            label: 'High',
            isSelected: false,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('High'), findsOneWidget);

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('SeverityOption border changes when selected', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeverityOption(label: 'Low', isSelected: true, onTap: () {}),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    final border = decoration.border as Border;

    expect(border.top.width, 2);
    expect(border.top.color, Colors.blueAccent);
  });
}
