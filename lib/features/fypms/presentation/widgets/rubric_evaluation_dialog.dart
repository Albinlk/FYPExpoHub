import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_rubric.dart';
import '../../../../core/domain/models/fypms/fyp_form_submission.dart';
import '../../../../core/state/fypms_state_providers.dart';

/// Scores one form submission against its textbook rubric: one 0–10 score per
/// criterion with its band and marks (W × S), and a live total that matches
/// the percentage the server stores.
class RubricEvaluationDialog extends ConsumerStatefulWidget {
  const RubricEvaluationDialog({super.key, required this.submission, required this.role});

  final FypFormSubmission submission;

  /// supervisor | examiner | lecturer | coordinator — decides whether
  /// supervisor-only criteria are shown.
  final String role;

  @override
  ConsumerState<RubricEvaluationDialog> createState() => _RubricEvaluationDialogState();
}

class _RubricEvaluationDialogState extends ConsumerState<RubricEvaluationDialog> {
  final _scores = <String, int>{};
  final _comments = TextEditingController();
  String _decision = 'approved';
  bool _submitting = false;

  @override
  void dispose() {
    _comments.dispose();
    super.dispose();
  }

  List<RubricCriterion> _criteriaOf(List<Map<String, dynamic>> raw) =>
      criteriaFor([for (final m in raw) RubricCriterion.fromMap(m)], widget.role);

  Future<void> _submit(List<RubricCriterion> criteria) async {
    setState(() => _submitting = true);
    try {
      await ref.read(submitFormEvaluationProvider)(
        widget.submission.id,
        {for (final c in criteria) c.key: _scores[c.key]},
        _comments.text.trim().isEmpty ? null : _comments.text.trim(),
        _decision,
        widget.submission.fypRecordId,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Evaluation submitted.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rubric = ref.watch(fypActiveRubricProvider(widget.submission.formCode));
    final criteria = rubric.value == null ? null : _criteriaOf(rubric.value!.criteria);
    // Submit only once every criterion has a score.
    final ready = criteria != null && criteria.every((c) => _scores.containsKey(c.key));

    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Evaluate Submission', style: DesignSystem.h2),
      content: SizedBox(
        width: 560,
        child: rubric.when(
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Could not load the rubric: $e'),
          data: (template) => template == null
              ? Text('No rubric is set up for ${widget.submission.formCode}.')
              : _buildForm(template.rubricName, criteria!),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: ready && !_submitting ? () => _submit(criteria) : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildForm(String rubricName, List<RubricCriterion> criteria) {
    final marks = rubricMarks(criteria, _scores);
    final scored = criteria.where((c) => _scores.containsKey(c.key)).length;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rubricName, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Score each criterion 0–10: 8–10 Excellent, 6–7 Good, 5 Satisfactory, 1–4 Poor, 0 No evidence.',
            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          for (final c in criteria) _buildCriterionRow(c),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  scored < criteria.length
                      ? 'Scored $scored of ${criteria.length} criteria'
                      : 'Marks ${marks.earned} / ${marks.possible}',
                  style: DesignSystem.bodySm,
                ),
              ),
              Text(
                '${rubricPercentage(criteria, _scores).toStringAsFixed(1)}%',
                key: const Key('rubric-total'),
                style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          DropdownButtonFormField<String>(
            initialValue: _decision,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Decision'),
            items: const [
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              DropdownMenuItem(value: 'resubmission_required', child: Text('Resubmission Required')),
            ],
            onChanged: (v) => setState(() => _decision = v!),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          TextField(
            controller: _comments,
            decoration: const InputDecoration(labelText: 'Comments'),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(RubricCriterion c) {
    final score = _scores[c.key];
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.label, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  [
                    'Weight ${c.weight}',
                    ?c.clo,
                    if (score != null) '${rubricBand(score)} · ${score * c.weight} marks',
                  ].join(' · '),
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignSystem.spaceSm),
          SizedBox(
            width: 112,
            child: DropdownButtonFormField<int>(
              key: Key('score-${c.key}'),
              initialValue: score,
              isDense: true,
              isExpanded: true,
              hint: const Text('Score'),
              items: [
                for (var v = c.max; v >= 0; v--) DropdownMenuItem(value: v, child: Text('$v')),
              ],
              onChanged: (v) => setState(() => _scores[c.key] = v!),
            ),
          ),
        ],
      ),
    );
  }
}
