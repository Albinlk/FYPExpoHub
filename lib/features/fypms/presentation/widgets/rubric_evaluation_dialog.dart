import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_form_definitions.dart';
import '../../../../core/domain/fypms_rubric.dart';
import '../../../../core/domain/models/fypms/fyp_form_submission.dart';
import '../../../../core/state/expo/service_providers.dart';
import '../../../../core/state/fypms/user_scope.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/supabase/fypms_database_service.dart';
import '../../../../core/utils/fypms_format.dart';
import 'student_form_dialog.dart' show FormAnswersView;
import '../../../../core/widgets/async_state.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/layout/responsive.dart';

/// The caller's own earlier evaluation of a submission (fyp_form_evaluations
/// row), used to prefill the dialog when they update it.
class ExistingFormEvaluation {
  const ExistingFormEvaluation({required this.scores, this.comments, this.evaluatedAt});

  /// Criterion key -> 0–10 score, from the `scores` jsonb.
  final Map<String, int> scores;
  final String? comments;
  final DateTime? evaluatedAt;

  /// Parses a fyp_form_evaluations row. Scores may arrive as int, double or
  /// numeric strings; anything else is skipped.
  factory ExistingFormEvaluation.fromRow(Map<String, dynamic> row) {
    final raw = row['scores'];
    final scores = <String, int>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        final v = e.value;
        final n = v is num ? v : (v is String ? num.tryParse(v) : null);
        if (n != null) scores['${e.key}'] = n.round();
      }
    }
    final comments = row['comments'];
    final at = row['evaluated_at'] ?? row['updated_at'];
    return ExistingFormEvaluation(
      scores: scores,
      comments: comments is String && comments.trim().isNotEmpty ? comments : null,
      evaluatedAt: at is String ? DateTime.tryParse(at) : (at is DateTime ? at : null),
    );
  }
}

/// The signed-in evaluator's own evaluation of a form submission, or null
/// when they have not evaluated it yet. Never fails: a load problem just
/// means the dialog opens empty, as it did before.
final myFormEvaluationProvider =
    FutureProvider.family<ExistingFormEvaluation?, String>((ref, formSubmissionId) async {
  try {
    final uid = ref.watch(fypmsUserScopeProvider);
    if (uid == null) return null;
    final rows = await ref.read(supabaseDbServiceProvider).getEvaluationsForSubmissionOnce(formSubmissionId);
    for (final row in rows) {
      if (row['evaluator_id'] == uid) return ExistingFormEvaluation.fromRow(row);
    }
    return null;
  } catch (_) {
    return null;
  }
});

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

  /// The evaluator's earlier evaluation, once loaded; its scores and
  /// comments are copied into the form unless the user already started.
  ExistingFormEvaluation? _existing;

  /// Bumped when prefilled values arrive so the dropdowns (which only read
  /// their initial value once) rebuild with them.
  int _prefillGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    ExistingFormEvaluation? existing;
    try {
      existing = await ref.read(myFormEvaluationProvider(widget.submission.id).future);
    } catch (_) {
      existing = null;
    }
    if (!mounted || existing == null) return;
    final e = existing;
    setState(() {
      _existing = e;
      // Do not overwrite anything the evaluator already changed.
      if (_scores.isEmpty) _scores.addAll(e.scores);
      if (_comments.text.isEmpty && e.comments != null) _comments.text = e.comments!;
      const decisions = {'approved', 'rejected', 'resubmission_required'};
      if (decisions.contains(widget.submission.status)) _decision = widget.submission.status;
      _prefillGeneration++;
    });
  }

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
      ref.invalidate(myFormEvaluationProvider(widget.submission.id));
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(_existing == null ? 'Evaluation submitted.' : 'Evaluation updated.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rubric = ref.watch(fypActiveRubricProvider(widget.submission.formCode));
    final criteria = rubric.value == null ? null : _criteriaOf(rubric.value!.criteria);
    // Submit only once every criterion has a score.
    // Ignore stored scores for criteria the current rubric no longer has.
    final ready = criteria != null && criteria.every((c) => _scores.containsKey(c.key));

    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Evaluate Submission', style: DesignSystem.h2),
      content: SizedBox(
        width: dialogWidth(context, 560),
        child: rubric.when(
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypActiveRubricProvider(widget.submission.formCode)), what: 'the rubric'),
          data: (template) => template == null
              ? Text('No rubric is set up for ${widget.submission.formCode}.')
              : _buildForm(template.rubricName, criteria!),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: ready && !_submitting ? () => _submit(criteria) : null,
          child: Text(_existing == null ? 'Submit' : 'Update'),
        ),
      ],
    );
  }

  Widget _buildForm(String rubricName, List<RubricCriterion> criteria) {
    final marks = rubricMarks(criteria, _scores);
    final scored = criteria.where((c) => _scores.containsKey(c.key)).length;
    final existing = _existing;
    return SingleChildScrollView(
      key: ValueKey('rubric-form-$_prefillGeneration'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (existing != null) ...[
            Text(
              existing.evaluatedAt == null
                  ? 'You already evaluated this submission. Your scores and comments are filled in; change them and press Update.'
                  : 'You evaluated this submission on ${formatFypDate(existing.evaluatedAt!)}. '
                      'Your scores and comments are filled in; change them and press Update.',
              key: const Key('existing-evaluation-note'),
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: DesignSystem.spaceSm),
          ],
          // What the student submitted (backlog U1), above the scores.
          if (formAnswers(widget.submission.formCode, widget.submission.payload).isNotEmpty) ...[
            Text('Student submission', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            FormAnswersView(formCode: widget.submission.formCode, payload: widget.submission.payload),
            const Divider(height: 24),
          ],
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
