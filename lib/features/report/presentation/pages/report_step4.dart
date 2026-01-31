import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step5.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';

class ReportStep4 extends ConsumerStatefulWidget {
  const ReportStep4({super.key});

  @override
  ConsumerState<ReportStep4> createState() => _ReportStep4State();
}

class _ReportStep4State extends ConsumerState<ReportStep4> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportFormDraftProvider);
    titleController = TextEditingController(text: draft.issueTitle);
    descriptionController = TextEditingController(text: draft.issueDescription);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Report Issue")),
      body: Column(
        children: [
          // Progress section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                ReportProgressBar(currentStep: 4, totalSteps: 6),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Describe the Issue",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Provide clear details to help resolve it faster",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  const Text("Issue Title *"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "e.g., Large pothole causing traffic issues",
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text("Detailed Description *"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText:
                          "Describe the issue in detail... What is the problem? When did you notice it?",
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final description = descriptionController.text.trim();
                      if (title.isEmpty) {
                        showMySnackBar(
                          context: context,
                          message: 'Issue title is required.',
                          isError: true,
                          icon: Icons.info_outline,
                        );
                        return;
                      }
                      if (description.isEmpty) {
                        showMySnackBar(
                          context: context,
                          message: 'Detailed description is required.',
                          isError: true,
                          icon: Icons.info_outline,
                        );
                        return;
                      }

                      ref
                          .read(reportFormDraftProvider.notifier)
                          .setIssueDetails(
                            title: title,
                            description: description,
                          );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(
                            name: ReportRouteNames.step5,
                          ),
                          builder: (context) => const ReportStep5(),
                        ),
                      );
                    },
                    child: const Text("Continue"),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
