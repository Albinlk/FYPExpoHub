import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_course_marks.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

/// Course marks computed from the rubric evaluations (textbook shares), with
/// a Finalize action once every evaluator has scored.
class CspMarksPage extends ConsumerWidget {
  const CspMarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(fypRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Finalize Marks',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No records found to finalize marks.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: list.length,
            itemBuilder: (context, index) => _RecordMarksSection(record: list[index]),
          );
        },
      ),
    );
  }
}

class _RecordMarksSection extends ConsumerWidget {
  const _RecordMarksSection({required this.record});

  final FypRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(fypMarksSummariesProvider(record.id));
    final finalized = summaries.value?.any(
          (s) => s.isFinalized && s.courseCode == record.currentCourseCode,
        ) ??
        false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceSm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  record.projectTitle ?? 'Untitled Project',
                  style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                ),
              ),
              if (!finalized)
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _CourseMarksDialog(record: record),
                  ),
                  icon: const Icon(Icons.grade, size: 18),
                  label: const Text('Finalize'),
                ),
            ],
          ),
        ),
        summaries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No marks finalized yet.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                for (final s in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.analytics, color: DesignSystem.primary),
                      title: Text('${s.courseCode} — Grade: ${s.grade ?? 'N/A'}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Weighted Total: ${s.weightedTotal.toStringAsFixed(2)} / 100', style: DesignSystem.bodySm),
                      trailing: s.isFinalized
                          ? const Icon(Icons.check_circle, color: DesignSystem.secondary)
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: DesignSystem.spaceLg),
      ],
    );
  }
}

/// The computed breakdown for one record, and Finalize when complete.
class _CourseMarksDialog extends ConsumerStatefulWidget {
  const _CourseMarksDialog({required this.record});

  final FypRecord record;

  @override
  ConsumerState<_CourseMarksDialog> createState() => _CourseMarksDialogState();
}

class _CourseMarksDialogState extends ConsumerState<_CourseMarksDialog> {
  bool _finalizing = false;

  Future<void> _finalize() async {
    setState(() => _finalizing = true);
    try {
      await ref.read(finalizeCourseMarksProvider)(widget.record.id);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Marks finalized.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _finalizing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final marks = ref.watch(fypCourseMarksProvider(widget.record.id));
    final complete = marks.value?.complete ?? false;

    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Finalize Course Marks', style: DesignSystem.h2),
      content: SizedBox(
        width: 560,
        child: marks.when(
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Could not compute marks: $e'),
          data: _buildBreakdown,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: complete && !_finalizing ? _finalize : null,
          child: const Text('Finalize'),
        ),
      ],
    );
  }

  Widget _buildBreakdown(CourseMarks m) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${m.courseCode}: each evaluator\'s share × their rubric score.',
            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
          const SizedBox(height: DesignSystem.spaceSm),
          for (final c in m.components)
            _row(
              c.label,
              '${c.percent!.toStringAsFixed(1)}% of ${_n(c.share)}',
              c.contribution!.toStringAsFixed(2),
            ),
          if (m.missing.isNotEmpty) ...[
            const SizedBox(height: DesignSystem.spaceSm),
            Text(
              'Still missing (${m.missing.length})',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.error, fontWeight: FontWeight.bold),
            ),
            for (final c in m.missing)
              _row(
                c.label,
                c.reason == 'no_submission' ? 'not submitted' : 'not evaluated',
                '— / ${_n(c.share)}',
                muted: true,
              ),
          ],
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  m.complete ? 'Total' : 'Total so far',
                  style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${m.total.toStringAsFixed(2)} / ${_n(m.allocated)}'
                '${m.complete && m.grade != null ? '  ·  ${m.grade}' : ''}',
                key: const Key('course-total'),
                style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary),
              ),
            ],
          ),
          if (!m.complete)
            Padding(
              padding: const EdgeInsets.only(top: DesignSystem.spaceSm),
              child: Text(
                'Marks can be finalized once every evaluation is in.',
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  static String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Widget _row(String label, String detail, String value, {bool muted = false}) {
    final color = muted ? DesignSystem.onSurfaceVariant : DesignSystem.onBackground;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(label, style: DesignSystem.bodySm.copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 4,
            child: Text(detail, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
          ),
          SizedBox(
            width: 64,
            child: Text(value, textAlign: TextAlign.right, style: DesignSystem.bodySm.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
