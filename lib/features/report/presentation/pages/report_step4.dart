import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step5.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_app_bar.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const ReportAppBar(title: 'Report Issue'),
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const ReportProgressBar(currentStep: 4, totalSteps: 6),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Describe the Issue',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Provide clear details to help resolve it faster',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _IssueDetailsInputCard(
              titleController: titleController,
              descriptionController: descriptionController,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                      .setIssueDetails(title: title, description: description);

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
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back"),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _IssueDetailsInputCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const _IssueDetailsInputCard({
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Issue Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE6EAF2)),
          const SizedBox(height: 14),
          _IssueInputField(
            controller: titleController,
            labelText: 'Issue Title',
            hintText: 'e.g., Large pothole causing traffic issues',
            icon: Icons.title_rounded,
            iconColor: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),
          _IssueInputField(
            controller: descriptionController,
            labelText: 'Detailed Description',
            hintText:
                'Describe the issue in detail... What is the problem? When did you notice it?',
            icon: Icons.notes_rounded,
            iconColor: const Color(0xFF7C3AED),
            maxLines: 5,
            maxLength: 500,
          ),
        ],
      ),
    );
  }
}

class _IssueInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final Color iconColor;
  final int? maxLines;
  final int? maxLength;

  const _IssueInputField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.iconColor,
    this.maxLines,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$labelText *',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8F97A6),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFB6BDCA),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, size: 22, color: iconColor),
            filled: true,
            fillColor: const Color(0xFFF3F5FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE4E7EF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE4E7EF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: iconColor.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
