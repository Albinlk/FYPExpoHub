import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_special_evaluation.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';

/// F14: the CSP650 lecturer checks the four textbook conditions for special
/// evaluation. Progress + LMC comes from the F9 / F13 evaluations; the final
/// report and exhibition visit are suggested from the record, and the
/// lecturer confirms checks 2-4. Qualifying opens F15 / F16 for the student.
class SpecialEvaluationDialog extends ConsumerStatefulWidget {
  const SpecialEvaluationDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<SpecialEvaluationDialog> createState() => _SpecialEvaluationDialogState();
}

class _SpecialEvaluationDialogState extends ConsumerState<SpecialEvaluationDialog> {
  final _note = TextEditingController();
  bool? _chapters;
  bool? _presented;
  bool? _coursesPassed;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Start from the saved decision, else from what the system can tell.
  void _seed(SpecialEvaluationChecks c) {
    if (_chapters != null) return;
    final a = c.assessment;
    _chapters = a?.chaptersComplete ?? c.finalReportSubmitted;
    _presented = a?.presentedAtExhibition ?? c.exhibitionVisitRecorded;
    _coursesPassed = a?.finalSemesterCoursesPassed ?? false;
    _note.text = a?.note ?? '';
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(assessSpecialEvaluationProvider)(
        fypRecordId: widget.record.id,
        chaptersComplete: _chapters ?? false,
        presentedAtExhibition: _presented ?? false,
        finalSemesterCoursesPassed: _coursesPassed ?? false,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('F14 decision saved.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final checks = ref.watch(fypSpecialEvaluationChecksProvider(widget.record.id));
    final c = checks.value;
    if (c != null) _seed(c);
    final qualifies = c != null &&
        c.progressMet &&
        (_chapters ?? false) &&
        (_presented ?? false) &&
        (_coursesPassed ?? false);

    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('F14 — Special Evaluation', style: DesignSystem.h2),
      content: SizedBox(
        width: 560,
        child: checks.when(
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Could not load the checks: $e'),
          data: (c) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.record.projectTitle ?? 'Untitled Project',
                  style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                ListTile(
                  key: const Key('f14-progress'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    c.progressMet ? Icons.check_circle : Icons.cancel,
                    color: c.progressMet ? DesignSystem.secondary : DesignSystem.error,
                  ),
                  title: const Text('Progress (F9) + Lean Model Canvas (F13) ≥ 7.5 %'),
                  subtitle: Text(
                    '${c.progressLmcMarks.toStringAsFixed(2)} of 15'
                    '${c.progressLmcComplete ? '' : ' — F9 / F13 not fully evaluated yet'}',
                  ),
                ),
                CheckboxListTile(
                  key: const Key('f14-chapters'),
                  contentPadding: EdgeInsets.zero,
                  value: _chapters ?? false,
                  onChanged: (v) => setState(() => _chapters = v),
                  title: const Text('Complete chapters 1–5 submitted'),
                  subtitle: Text(c.finalReportSubmitted ? 'Final report on file' : 'No final report submitted yet'),
                ),
                CheckboxListTile(
                  key: const Key('f14-presented'),
                  contentPadding: EdgeInsets.zero,
                  value: _presented ?? false,
                  onChanged: (v) => setState(() => _presented = v),
                  title: const Text('Presented at the exhibition'),
                  subtitle: Text(
                    c.exhibitionVisitRecorded ? 'An exhibition visit was recorded' : 'No exhibition visit recorded',
                  ),
                ),
                CheckboxListTile(
                  key: const Key('f14-courses'),
                  contentPadding: EdgeInsets.zero,
                  value: _coursesPassed ?? false,
                  onChanged: (v) => setState(() => _coursesPassed = v),
                  title: const Text('Final semester, all other courses passed'),
                  subtitle: const Text('Confirm from the academic record'),
                ),
                TextField(
                  controller: _note,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                Text(
                  qualifies
                      ? 'Qualifies — F15 and F16 open for this student.'
                      : 'Does not qualify — F15 and F16 stay closed.',
                  key: const Key('f14-outcome'),
                  style: DesignSystem.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: qualifies ? DesignSystem.secondary : DesignSystem.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: c != null && !_busy ? _save : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// One-line F14 status for a record ("Qualified", "Not qualified", …).
String specialEvaluationStatusLabel(SpecialEvaluation? s) {
  if (s == null) return 'Not assessed';
  return s.eligible ? 'Qualified for special evaluation' : 'Not qualified';
}
