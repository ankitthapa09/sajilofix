import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step2.dart';
import 'package:sajilofix/features/report/presentation/widgets/report_category_card.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_app_bar.dart';
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
      appBar: const ReportAppBar(title: 'Report Issue'),
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportProgressBar(currentStep: 1, totalSteps: 6),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "What's the issue?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Select the category that best describes the problem',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return ReportCategoryCard(
                      iconpath: item['icon'],
                      title: item['title'],
                      isSelected: selectedIndex == index,
                      onTap: () {
                        ref
                            .read(reportFormDraftProvider.notifier)
                            .setCategory(item['title'] as String);
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedIndex == -1
                      ? null
                      : () {
                          final selectedCategoryTitle =
                              categories[selectedIndex]['title'] as String;
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
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
