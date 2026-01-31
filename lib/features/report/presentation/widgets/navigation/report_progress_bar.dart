import 'package:flutter/material.dart';

class ReportProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ReportProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color.fromARGB(255, 195, 214, 245),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 58, 106, 202),
            ),
          ),
        ),
      ],
    );
  }
}
