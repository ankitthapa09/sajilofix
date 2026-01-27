import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_app_bar.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step6.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';

class ReportStep5 extends ConsumerStatefulWidget {
  const ReportStep5({super.key});

  @override
  ConsumerState<ReportStep5> createState() => _ReportStep5State();
}

class _ReportStep5State extends ConsumerState<ReportStep5> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportFormDraftProvider);
    _selected = (draft.urgency ?? '').trim();
  }

  void _select(String value) {
    ref.read(reportFormDraftProvider.notifier).setUrgency(value);
    setState(() => _selected = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const ReportAppBar(title: 'Report Issue'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                SizedBox(height: 8),
                ReportProgressBar(currentStep: 5, totalSteps: 6),
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
                    'Set Urgency Level',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Help us prioritize and respond to your issue appropriately',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  _UrgencyCard(
                    title: 'Low Priority',
                    subtitle:
                        'Minor issue that can be addressed in normal timeframe',
                    icon: Icons.info_outline,
                    background: const Color(0xFFEAF2FF),
                    border: const Color(0xFF3A6ACA),
                    selected: _selected == 'Low Priority',
                    onTap: () => _select('Low Priority'),
                  ),
                  const SizedBox(height: 14),
                  _UrgencyCard(
                    title: 'Medium Priority',
                    subtitle:
                        'Issue that should be handled soon but isn\'t an emergency',
                    icon: Icons.error_outline,
                    background: const Color(0xFFFFF7DC),
                    border: const Color(0xFFB07B00),
                    selected: _selected == 'Medium Priority',
                    onTap: () => _select('Medium Priority'),
                  ),
                  const SizedBox(height: 14),
                  _UrgencyCard(
                    title: 'High Priority',
                    subtitle: 'Significant issue needing prompt resolution',
                    icon: Icons.warning_amber_rounded,
                    background: const Color(0xFFFFEEE5),
                    border: const Color(0xFFEB6A2A),
                    selected: _selected == 'High Priority',
                    onTap: () => _select('High Priority'),
                  ),
                  const SizedBox(height: 14),
                  _UrgencyCard(
                    title: 'Urgent',
                    subtitle:
                        'Critical issue requiring immediate attention for safety/health',
                    icon: Icons.report_gmailerrorred_outlined,
                    background: const Color(0xFFFFE8E8),
                    border: const Color(0xFFE53935),
                    selected: _selected == 'Urgent',
                    onTap: () => _select('Urgent'),
                  ),

                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFD3FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Note: Urgent issues will be prioritized for immediate attention. '
                            'Please only mark as urgent if the issue poses immediate safety or health risks.',
                            style: TextStyle(color: Color(0xFF2A4B8D)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _selected.trim().isEmpty
                        ? null
                        : () {
                            ref
                                .read(reportFormDraftProvider.notifier)
                                .setUrgency(_selected);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: const RouteSettings(
                                  name: ReportRouteNames.step6,
                                ),
                                builder: (context) => const ReportStep6(),
                              ),
                            );
                          },
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color border;
  final bool selected;
  final VoidCallback onTap;

  const _UrgencyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.border,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color effectiveBackground = selected
        ? Color.alphaBlend(border.withOpacity(0.10), background)
        : background;
    final Color effectiveBorder = selected
        ? border
        : scheme.outlineVariant.withOpacity(0.25);
    final Color iconBg = selected
        ? border.withOpacity(0.14)
        : Colors.white.withOpacity(0.85);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveBorder, width: selected ? 2 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: border),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 120),
                        child: Icon(
                          Icons.check_circle,
                          size: 18,
                          color: border,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.68),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
