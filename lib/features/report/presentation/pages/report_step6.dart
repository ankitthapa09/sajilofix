import 'package:flutter/material.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/core/widgets/report_app_bar.dart';
import 'package:sajilofix/core/widgets/report_progress_bar.dart';

class ReportStep6 extends StatelessWidget {
  final String? category;
  final String? location;
  final String? landmark;
  final String? issueTitle;
  final String? issueDescription;
  final String? urgency;

  const ReportStep6({
    super.key,
    this.category,
    this.location,
    this.landmark,
    this.issueTitle,
    this.issueDescription,
    this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ReportAppBar(title: 'Report Issue'),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 8),
                ReportProgressBar(currentStep: 6, totalSteps: 6),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review & Submit',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please review your report before submitting',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 18),

                  _ReviewSection(
                    title: 'Category',
                    onEdit: () => _popSteps(context, 5),
                    child: Text(
                      category ?? 'Not selected',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _ReviewSection(
                    title: 'Location',
                    onEdit: () => _popSteps(context, 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location ?? 'Not selected',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((landmark ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Near: ${landmark!.trim()}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _ReviewSection(
                    title: 'Issue Details',
                    onEdit: () => _popSteps(context, 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (issueTitle ?? '').trim().isEmpty
                              ? 'No title'
                              : issueTitle!.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (issueDescription ?? '').trim().isEmpty
                              ? 'No description'
                              : issueDescription!.trim(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _ReviewSection(
                    title: 'Photos',
                    onEdit: () => _popSteps(context, 4),
                    child: Row(children: [_PhotoTile(label: 'Photo 1')]),
                  ),
                  const SizedBox(height: 14),

                  _ReviewSection(
                    title: 'Urgency Level',
                    onEdit: () => _popSteps(context, 1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _UrgencyIcon(urgency: urgency),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (urgency ?? '').trim().isEmpty
                                    ? 'Not selected'
                                    : urgency!.trim(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _urgencySubtitle(urgency),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _GuidelinesNotice(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientElevatedButton(
              text: 'Submit Report',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Submitted (UI only for now).')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _popSteps(BuildContext context, int count) {
  for (var i = 0; i < count; i++) {
    if (!Navigator.of(context).canPop()) return;
    Navigator.of(context).pop();
  }
}

String _urgencySubtitle(String? urgency) {
  switch ((urgency ?? '').trim().toLowerCase()) {
    case 'low priority':
      return 'Minor issue that can be addressed in normal timeframe';
    case 'medium priority':
      return 'Moderate issue requiring attention within a few days';
    case 'high priority':
      return 'Significant issue needing prompt resolution';
    case 'urgent':
      return 'Critical issue posing immediate safety or health risk';
    default:
      return 'Select an urgency level to help us prioritize';
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final Widget child;

  const _ReviewSection({
    required this.title,
    required this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String label;

  const _PhotoTile({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.image_outlined,
                color: scheme.onSurface.withOpacity(0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyIcon extends StatelessWidget {
  final String? urgency;

  const _UrgencyIcon({required this.urgency});

  @override
  Widget build(BuildContext context) {
    final normalized = (urgency ?? '').trim().toLowerCase();

    Color color;
    IconData icon;
    if (normalized == 'urgent') {
      color = const Color(0xFFE53935);
      icon = Icons.error_outline;
    } else if (normalized == 'high priority') {
      color = const Color(0xFFEB6A2A);
      icon = Icons.warning_amber_rounded;
    } else if (normalized == 'medium priority') {
      color = const Color(0xFFB07B00);
      icon = Icons.error_outline;
    } else {
      color = const Color(0xFF3A6ACA);
      icon = Icons.info_outline;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _GuidelinesNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9E5C7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'By submitting this report, you confirm that the information provided is accurate and you agree to our community guidelines.',
              style: TextStyle(
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
