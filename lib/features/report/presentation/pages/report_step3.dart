import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step4.dart';
import 'package:sajilofix/features/report/presentation/widgets/location/map_placeholder.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';
import 'package:sajilofix/core/services/app_permissions.dart';

class ReportStep3 extends ConsumerStatefulWidget {
  const ReportStep3({super.key});

  @override
  ConsumerState<ReportStep3> createState() => _ReportStep3State();
}

class _ReportStep3State extends ConsumerState<ReportStep3> {
  late final TextEditingController _addressController;
  late final TextEditingController _municipalityController;
  late final TextEditingController _districtController;
  late final TextEditingController _wardController;
  late final TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportFormDraftProvider);
    _addressController = TextEditingController(text: draft.locationTitle);
    _municipalityController = TextEditingController(
      text: draft.locationSubtitle,
    );
    _districtController = TextEditingController(text: draft.district);
    _wardController = TextEditingController(text: draft.ward);
    _landmarkController = TextEditingController(text: draft.landmark);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _municipalityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Report Screen")),
      body: ListView(
        padding: const EdgeInsets.all(18),
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
            onPressed: () async {
              final ok = await AppPermissions.ensureLocationWhenInUse(context);
              if (!ok || !context.mounted) return;

              showMySnackBar(
                context: context,
                message: 'Location permission granted.',
                icon: Icons.check_circle_outline,
              );
            },
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

          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address *',
              hintText: 'Street, area, or nearby address',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _municipalityController,
            decoration: const InputDecoration(
              labelText: 'Municipality *',
              hintText: 'Enter municipality/city',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _districtController,
            decoration: const InputDecoration(
              labelText: 'District *',
              hintText: 'Enter district',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _wardController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ward *',
              hintText: 'Enter ward number',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _landmarkController,
            decoration: const InputDecoration(
              labelText: 'Landmark *',
              hintText: 'Enter a nearby landmark or address',
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final address = _addressController.text.trim();
                final municipality = _municipalityController.text.trim();
                final district = _districtController.text.trim();
                final ward = _wardController.text.trim();
                final landmark = _landmarkController.text.trim();

                if (address.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter an address to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                if (municipality.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter municipality to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                if (district.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter district to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                if (ward.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter ward to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

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
                      title: address,
                      subtitle: municipality,
                      landmark: landmark,
                      district: district,
                      ward: ward,
                    );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: ReportRouteNames.step4),
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
    );
  }
}
