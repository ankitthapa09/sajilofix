import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step2.dart';
import 'package:sajilofix/features/report/presentation/widgets/report_category_card.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';

class ReportStep1 extends ConsumerStatefulWidget {
  const ReportStep1({super.key});

  @override
  ConsumerState<ReportStep1> createState() => _ReportStep1State();
}

class _ReportStep1State extends ConsumerState<ReportStep1> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> categories = [
    {"icon": "assets/icons/pothole.png", "title": "Roads & Potholes"},
    {"icon": "assets/icons/energy-saving.png", "title": "Electricity"},
    {"icon": "assets/icons/water-tap.png", "title": "Water Supply"},
    {"icon": "assets/icons/trash-can.png", "title": "Waste Management"},
    {"icon": "assets/icons/street-light.png", "title": "Street Lights"},
    {"icon": "assets/icons/constructor.png", "title": "Public Infrastructure"},
    {"icon": "assets/icons/other-issues.png", "title": "Other"},
  ];

  @override
  void initState() {
    super.initState();
    final selectedCategory = ref.read(reportFormDraftProvider).category;
    if (selectedCategory == null) return;
    final index = categories.indexWhere(
      (e) => (e['title'] as String?) == selectedCategory,
    );
    if (index >= 0) {
      selectedIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Issue"),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // for Progress Bar
            const ReportProgressBar(currentStep: 1, totalSteps: 6),

            const SizedBox(height: 30),

            const Text(
              "What's the issue?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select the category that best describes the problem",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return ReportCategoryCard(
                    iconpath: item["icon"],
                    title: item["title"],
                    isSelected: selectedIndex == index,
                    onTap: () {
                      ref
                          .read(reportFormDraftProvider.notifier)
                          .setCategory(item["title"] as String);
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),

            // for Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedIndex == -1
                    ? null
                    : () {
                        final selectedCategoryTitle =
                            categories[selectedIndex]["title"] as String;
                        ref
                            .read(reportFormDraftProvider.notifier)
                            .setCategory(selectedCategoryTitle);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(
                              name: ReportRouteNames.step2,
                            ),
                            builder: (context) => const ReportStep2(),
                          ),
                        );
                      },
                child: const Text("Continue"),
              ),
            ),

            const SizedBox(height: 9),

            // Center(
            //   child: TextButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     child: const Text("Back"),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
