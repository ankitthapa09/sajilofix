import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step4.dart';
import 'package:sajilofix/features/report/presentation/widgets/location/location_card.dart';
import 'package:sajilofix/features/report/presentation/widgets/location/map_placeholder.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';

class ReportStep3 extends ConsumerStatefulWidget {
  const ReportStep3({super.key});

  @override
  ConsumerState<ReportStep3> createState() => _ReportStep3State();
}

class _ReportStep3State extends ConsumerState<ReportStep3> {
  late final TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();
    _landmarkController = TextEditingController(
      text: ref.read(reportFormDraftProvider).landmark,
    );
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const locationTitle = "Kathmandu Metropolitan City";
    const locationSubtitle = "Kathmandu";

    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Report Screen")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReportProgressBar(currentStep: 3, totalSteps: 6),

            const Divider(),

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
              controller: _landmarkController,
              decoration: const InputDecoration(
                labelText: 'Landmark *',
                hintText: 'Enter a nearby landmark or address',
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final landmark = _landmarkController.text.trim();
                  if (landmark.isEmpty) {
                    showMySnackBar(
                      context: context,
                      message: 'Please enter a landmark to continue.',
                      isError: true,
                      icon: Icons.info_outline,
                    );
                    return;
                  }

                  ref
                      .read(reportFormDraftProvider.notifier)
                      .setLocation(
                        title: locationTitle,
                        subtitle: locationSubtitle,
                        landmark: landmark,
                      );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: ReportRouteNames.step4,
                      ),
                      builder: (context) => const ReportStep4(),
                    ),
                  );
                },
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
