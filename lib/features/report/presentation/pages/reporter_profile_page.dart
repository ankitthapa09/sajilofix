import 'package:flutter/material.dart';
import 'package:sajilofix/core/api/api_endpoints.dart';
import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/presentation/widgets/report_view/reporter_profile_widgets.dart';

class ReporterProfilePage extends StatelessWidget {
  final ReporterInfo reporter;

  const ReporterProfilePage({super.key, required this.reporter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporter Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReporterProfileHeader(
                reporter: reporter,
                baseUrl: ApiEndpoints.baseUrl,
              ),
              const SizedBox(height: 20),
              ReporterProfileStatusSection(reporter: reporter),
            ],
          ),
        ),
      ),
    );
  }
}
