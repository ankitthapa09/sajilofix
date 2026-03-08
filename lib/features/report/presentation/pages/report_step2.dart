import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/services/app_permissions.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step3.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';
import 'package:sajilofix/features/report/presentation/widgets/media/add_photo_card.dart';
import 'package:sajilofix/features/report/presentation/widgets/media/empty_photo_state.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_app_bar.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';

class ReportStep2 extends ConsumerStatefulWidget {
  const ReportStep2({super.key});

  @override
  ConsumerState<ReportStep2> createState() => _ReportStep2State();
}

class _ReportStep2State extends ConsumerState<ReportStep2> {
  static const int _maxPhotos = 3;

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
                  await _takePhoto(rootContext);
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
                  await _pickFromGallery(rootContext);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePhoto(BuildContext rootContext) async {
    final photos = ref.read(reportFormDraftProvider).photos;
    if (photos.length >= _maxPhotos) {
      showMySnackBar(
        context: rootContext,
        message: 'You can upload up to $_maxPhotos photos.',
        isError: true,
        icon: Icons.info_outline,
      );
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (!mounted) return;

    if (file == null) {
      showMySnackBar(
        context: rootContext,
        message: 'No photo captured.',
        icon: Icons.info_outline,
      );
      return;
    }

    ref.read(reportFormDraftProvider.notifier).addPhoto(file);
  }

  Future<void> _pickFromGallery(BuildContext rootContext) async {
    final photos = ref.read(reportFormDraftProvider).photos;
    final remaining = _maxPhotos - photos.length;
    if (remaining <= 0) {
      showMySnackBar(
        context: rootContext,
        message: 'You can upload up to $_maxPhotos photos.',
        isError: true,
        icon: Icons.info_outline,
      );
      return;
    }

    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85, maxWidth: 1600);

    if (!mounted) return;

    if (files.isEmpty) {
      showMySnackBar(
        context: rootContext,
        message: 'No photos selected.',
        icon: Icons.info_outline,
      );
      return;
    }

    final selected = files.take(remaining);
    for (final file in selected) {
      ref.read(reportFormDraftProvider.notifier).addPhoto(file);
    }

    if (files.length > remaining) {
      showMySnackBar(
        context: rootContext,
        message: 'Only $remaining photo(s) added.',
        icon: Icons.info_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photos = ref.watch(reportFormDraftProvider).photos;

    return Scaffold(
      appBar: const ReportAppBar(title: 'Report Issue'),
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const ReportProgressBar(currentStep: 2, totalSteps: 6),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Add Photos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Take or upload photos showing the issue clearly',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Evidence Photos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE6EAF2)),
                  const SizedBox(height: 14),
                  AddPhotoCard(onTap: _onAddPhotoTap),
                  const SizedBox(height: 16),
                  if (photos.isEmpty)
                    const EmptyPhotoState()
                  else
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final photo = photos[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: kIsWeb
                                    ? Image.network(
                                        photo.path,
                                        width: 120,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      )
                                    : FutureBuilder<Uint8List>(
                                        future: photo.readAsBytes(),
                                        builder: (context, snapshot) {
                                          final bytes = snapshot.data;
                                          if (bytes == null) {
                                            return Container(
                                              width: 120,
                                              height: 110,
                                              color: Colors.grey.shade200,
                                            );
                                          }
                                          return Image.memory(
                                            bytes,
                                            width: 120,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(reportFormDraftProvider.notifier)
                                        .removePhotoAt(index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                child: const Text('Continue'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
