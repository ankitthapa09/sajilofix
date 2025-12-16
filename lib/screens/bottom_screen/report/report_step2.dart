import 'package:flutter/material.dart';
import 'package:sajilofix/widgets/add_photo_card.dart';
import 'package:sajilofix/widgets/empty_photo_state.dart';
import 'package:sajilofix/widgets/report_app_bar.dart';
import 'package:sajilofix/widgets/report_progress_bar.dart';

class ReportStep2 extends StatelessWidget {
  const ReportStep2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ReportAppBar(title: "Report Issue"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReportProgressBar(currentStep: 2, totalSteps: 6),

            const SizedBox(height: 24),

            const Text(
              "Add Photos",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Take or upload photos showing the issue clearly",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            const AddPhotoCard(),
            const SizedBox(height: 40),

            const EmptyPhotoState(),
            const SizedBox(height: 24),

            // const TipCard(
            //   text: "Take photos from multiple angles for better clarity",
            // ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
