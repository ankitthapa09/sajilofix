import 'package:flutter/material.dart';
import 'package:sajilofix/widgets/location_card.dart';
import 'package:sajilofix/widgets/map_placeholder.dart';
import 'package:sajilofix/widgets/report_progress_bar.dart';

class ReportStep3 extends StatelessWidget {
  const ReportStep3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Report Screen")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReportProgressBar(currentStep: 3, totalSteps: 6),

            const SizedBox(height: 24),

            const Text(
              "Where is it?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              "Confirm the exact location of the issue",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            const MapPlaceholder(),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.my_location),
              label: const Text("Use Current Location"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const LocationCard(
              title: "Kathmandu Metropolitan City",
              subtitle: "Kathmandu",
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(
                hintText: "Add landmark or specific address (optional)",
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Continue"),
              ),
            ),

            const SizedBox(height: 10),

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
