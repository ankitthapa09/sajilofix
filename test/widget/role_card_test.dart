import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/features/auth/presentation/widgets/signup/role_card.dart';

void main() {
  testWidgets('RoleCard renders title/subtitle and triggers onTap', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoleCard(
            title: 'Citizen',
            subtitle: 'Report issues',
            icon: Icons.person,
            selected: false,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Citizen'), findsOneWidget);
    expect(find.text('Report issues'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('RoleCard uses thicker border when selected', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: RoleCard(
            title: 'Citizen',
            subtitle: 'Report issues',
            icon: Icons.person,
            selected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(RoleCard),
            matching: find.byType(Container),
          )
          .first,
    );

    final decoration = container.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top.width, 2);
  });
}
