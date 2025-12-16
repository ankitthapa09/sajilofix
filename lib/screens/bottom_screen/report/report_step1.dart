import 'package:flutter/material.dart';
import 'package:sajilofix/screens/bottom_screen/report/report_step2.dart';
import 'package:sajilofix/widgets/report_category_card.dart';
import 'package:sajilofix/widgets/report_progress_bar.dart';

class ReportStep1 extends StatefulWidget {
  const ReportStep1({super.key});

  @override
  State<ReportStep1> createState() => _ReportStep1State();
}

class _ReportStep1State extends State<ReportStep1> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.construction, "title": "Roads & Potholes"},
    {"icon": Icons.lightbulb, "title": "Electricity"},
    {"icon": Icons.water_drop, "title": "Water Supply"},
    {"icon": Icons.delete, "title": "Waste Management"},
    {"icon": Icons.lightbulb, "title": "Street Lights"},
    {"icon": Icons.apartment, "title": "Public Infrastructure"},
    {"icon": Icons.description, "title": "Other"},
  ];

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
                    icon: item["icon"],
                    title: item["title"],
                    isSelected: selectedIndex == index,
                    onTap: () {
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportStep2(),
                          ),
                        );
                      },
                child: const Text("Continue"),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
