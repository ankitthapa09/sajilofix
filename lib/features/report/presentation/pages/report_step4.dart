import 'package:flutter/material.dart';
import 'package:sajilofix/core/widgets/report_progress_bar.dart';
import 'package:sajilofix/core/widgets/severity_option.dart';

class ReportStep4 extends StatefulWidget {
  const ReportStep4({super.key});

  @override
  State<ReportStep4> createState() => _ReportStep4State();
}

class _ReportStep4State extends State<ReportStep4> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedSeverity = "Medium";

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

                  const SizedBox(height: 20),

                  const Text(
                    "How severe is this issue?",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SeverityOption(
                          label: "Low",
                          isSelected: selectedSeverity == "Low",
                          onTap: () {
                            setState(() {
                              selectedSeverity = "Low";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SeverityOption(
                          label: "Medium",
                          isSelected: selectedSeverity == "Medium",
                          onTap: () {
                            setState(() {
                              selectedSeverity = "Medium";
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SeverityOption(
                          label: "High",
                          isSelected: selectedSeverity == "High",
                          onTap: () {
                            setState(() {
                              selectedSeverity = "High";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SeverityOption(
                          label: "Urgent",
                          isSelected: selectedSeverity == "Urgent",
                          onTap: () {
                            setState(() {
                              selectedSeverity = "Urgent";
                            });
                          },
                        ),
                      ),
                    ],
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
                      // Go to Step 5
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
