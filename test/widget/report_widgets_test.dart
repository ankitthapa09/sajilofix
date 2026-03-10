import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/widgets/media/add_photo_card.dart';
import 'package:sajilofix/features/report/presentation/widgets/media/empty_photo_state.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/widgets/report_view/reporter_profile_widgets.dart';

ReporterInfo _reporter({
  String fullName = 'Ankit Sharma',
  String? email = 'ankit@example.com',
  String? phone = '9800000000',
  String? status = 'active',
  String? profilePhoto,
}) {
  return ReporterInfo(
    id: 'u1',
    fullName: fullName,
    email: email,
    phone: phone,
    status: status,
    profilePhoto: profilePhoto,
  );
}

void main() {
  testWidgets('ReportProgressBar shows current step text and percent', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ReportProgressBar(currentStep: 3, totalSteps: 6)),
      ),
    );

    expect(find.text('Step 3 of 6'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('ReportProgressBar uses correct indicator value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ReportProgressBar(currentStep: 2, totalSteps: 8)),
      ),
    );

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 0.25);
  });

  testWidgets('ReportProgressBar shows 100 percent at final step', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ReportProgressBar(currentStep: 6, totalSteps: 6)),
      ),
    );

    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('AddPhotoCard renders icon and text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddPhotoCard())),
    );

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.text('Add Photo'), findsOneWidget);
  });

  testWidgets('AddPhotoCard triggers callback on tap', (tester) async {
    var tapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AddPhotoCard(onTap: () => tapped++)),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('EmptyPhotoState shows helper texts and icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyPhotoState())),
    );

    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    expect(find.text('No photos added yet'), findsOneWidget);
    expect(find.text('Add at least one photo to continue'), findsOneWidget);
  });

  testWidgets('ReporterProfileHeader shows initials when no photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReporterProfileHeader(
            reporter: _reporter(fullName: 'Nabin Lama', profilePhoto: null),
            baseUrl: 'https://api.example.com',
          ),
        ),
      ),
    );

    expect(find.text('NL'), findsOneWidget);
    expect(find.text('Nabin Lama'), findsOneWidget);
  });

  testWidgets('ReporterProfileHeader shows active status label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReporterProfileHeader(
            reporter: _reporter(status: 'active'),
            baseUrl: 'https://api.example.com',
          ),
        ),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('ReporterProfileStatusSection shows mapped status text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReporterProfileStatusSection(
            reporter: _reporter(status: 'blocked'),
          ),
        ),
      ),
    );

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
  });

  testWidgets('ReporterProfileHeader hides empty email and phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReporterProfileHeader(
            reporter: _reporter(email: '', phone: '   '),
            baseUrl: 'https://api.example.com',
          ),
        ),
      ),
    );

    expect(find.text('ankit@example.com'), findsNothing);
    expect(find.text('9800000000'), findsNothing);
  });
}
