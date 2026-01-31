import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step3.dart';
import 'package:sajilofix/features/report/presentation/widgets/media/add_photo_card.dart';
import 'package:sajilofix/features/report/presentation/widgets/media/empty_photo_state.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_app_bar.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';
import 'package:sajilofix/core/services/app_permissions.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';

class ReportStep2 extends ConsumerStatefulWidget {
  const ReportStep2({super.key});

  @override
  ConsumerState<ReportStep2> createState() => _ReportStep2State();
}

class _ReportStep2State extends ConsumerState<ReportStep2> {
  Future<void> _onAddPhotoTap() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final rootContext = context;
                  final ok = await AppPermissions.ensureCamera(rootContext);
                  if (!rootContext.mounted) return;
                  if (!ok) return;
                  showMySnackBar(
                    context: rootContext,
                    message: 'Camera permission granted.',
                    icon: Icons.check_circle_outline,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final rootContext = context;
                  final ok = await AppPermissions.ensurePhotos(rootContext);
                  if (!rootContext.mounted) return;
                  if (!ok) return;
                  showMySnackBar(
                    context: rootContext,
                    message: 'Photos permission granted.',
                    icon: Icons.check_circle_outline,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

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

            AddPhotoCard(onTap: _onAddPhotoTap),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: ReportRouteNames.step3,
                      ),
                      builder: (context) => const ReportStep3(),
                    ),
                  );
                },
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
