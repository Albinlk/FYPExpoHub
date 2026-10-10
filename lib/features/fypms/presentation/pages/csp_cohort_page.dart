import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/academic_semester.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/widgets/async_state.dart';
import '../../../../core/widgets/busy_button.dart';
import '../widgets/semester_selector.dart' show PromoteRecordDialog;

/// CSP600 lecturer duties from the FSKM handbook (Table 2.1): assign an
/// examiner to each student (#19) and, at the end of the semester, hand the
/// cohort over to the CSP650 lecturer (#29) by promoting each passing record to
/// the next semester's CSP650. The server already allows both for a CSP600
/// lecturer; this is the page for them.
class CspCohortPage extends ConsumerWidget {
  const CspCohortPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(cspRecordsProvider);
    final directory = ref.watch(supervisorsDirectoryProvider).value ?? const <Map<String, dynamic>>[];
    final names = <String, String>{
      for (final s in directory)
        if (s['id'] is String) s['id'] as String: (s['display_name'] as String? ?? 'Staff member'),
    };

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.surfaceContainerLowest,
        foregroundColor: DesignSystem.primary,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: DesignSystem.outlineVariant)),
        title: Text('Examiners & Handover', style: DesignSystem.h3.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.bold)),
      ),
      body: records.whenUi(
        what: 'CSP600 records',
        onRetry: () => ref.invalidate(fypRecordsProvider),
        data: (all) {
          final cohort = [for (final r in all) if (r.currentCourseCode == 'CSP600') r];
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              Text(
                'Assign an examiner to each student before the proposal presentation. At the end of the '
                'semester, hand the cohort over: each student whose CSP600 marks are finalized and passed '
                'gets a CSP650 record in the next semester, keeping the title, supervisors and examiner.',
                style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const Key('handover-cohort'),
                  onPressed: cohort.isEmpty
                      ? null
                      : () => showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => HandoverCohortDialog(records: cohort),
                          ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Hand Over Cohort to CSP650'),
                ),
              ),
              const SizedBox(height: DesignSystem.spaceLg),
              if (cohort.isEmpty)
                const Text('No CSP600 records in the selected semester.')
              else
                for (final r in cohort)
                  Card(
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                    child: Padding(
                      padding: const EdgeInsets.all(DesignSystem.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.projectTitle?.isNotEmpty == true ? r.projectTitle! : 'Untitled project',
                            style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${r.matricId ?? 'No matric'} · ${r.programmeCode} · '
                            'Supervisor: ${names[r.mainSupervisorId] ?? (r.mainSupervisorId == null ? 'not assigned' : 'Staff member')}',
                            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                          ),
                          Text(
                            'Examiner: ${names[r.examinerId] ?? (r.examinerId == null ? 'not assigned' : 'Staff member')}',
                            style: DesignSystem.bodySm.copyWith(
                              color: r.examinerId == null ? DesignSystem.error : DesignSystem.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: DesignSystem.spaceSm),
                          Wrap(
                            spacing: DesignSystem.spaceSm,
                            runSpacing: DesignSystem.spaceXs,
                            children: [
                              OutlinedButton(
                                key: Key('assign-examiner-${r.id}'),
                                onPressed: () => showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AssignExaminerDialog(record: r),
                                ),
                                child: Text(r.examinerId == null ? 'Assign Examiner' : 'Change Examiner'),
                              ),
                              TextButton(
                                onPressed: () => showDialog<void>(
                                  context: context,
                                  builder: (_) => PromoteRecordDialog(
                                    fypRecordId: r.id,
                                    currentSemesterId: r.academicSemesterId,
                                    title: r.projectTitle ?? 'Untitled project',
                                  ),
                                ),
                                child: const Text('Promote to CSP650'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

/// Picks the examiner for one record. The server refuses the student's own
/// supervisor or co-supervisor (impartiality rule); that message is shown here.
class AssignExaminerDialog extends ConsumerStatefulWidget {
  const AssignExaminerDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<AssignExaminerDialog> createState() => _AssignExaminerDialogState();
}

class _AssignExaminerDialogState extends ConsumerState<AssignExaminerDialog> {
  String? _examinerId;
  bool _busy = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(assignExaminerProvider)(widget.record.id, _examinerId!);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Examiner assigned.')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not assign the examiner: ${friendlyError(e)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final directoryAsync = ref.watch(supervisorsDirectoryProvider);
    final staff = [
      for (final s in directoryAsync.value ?? const <Map<String, dynamic>>[])
        if (s['id'] is String && s['id'] != widget.record.mainSupervisorId) s,
    ];
    return AlertDialog(
      title: const Text('Assign Examiner'),
      content: SizedBox(
        width: dialogWidth(context, 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.record.projectTitle ?? 'Untitled project',
                style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              if (directoryAsync.hasError && !directoryAsync.hasValue)
                AsyncErrorView(
                  error: directoryAsync.error!,
                  what: 'the staff list',
                  onRetry: () => ref.invalidate(supervisorsDirectoryProvider),
                )
              else
                DropdownButtonFormField<String>(
                  key: const Key('examiner-picker'),
                  initialValue: _examinerId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Examiner',
                    helperText: 'Not the student\'s supervisor or co-supervisor.',
                  ),
                  items: [
                    for (final s in staff)
                      DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text(s['display_name'] as String? ?? 'Staff member', overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: _busy ? null : (v) => setState(() => _examinerId = v),
                ),
              if (_error != null) ...[
                const SizedBox(height: DesignSystem.spaceSm),
                Semantics(
                  liveRegion: true,
                  child: Text(_error!, style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        BusyButton(
          label: 'Assign Examiner',
          busyLabel: 'Assigning…',
          busy: _busy,
          onPressed: _examinerId == null ? null : _save,
        ),
      ],
    );
  }
}

/// Promotes every CSP600 record in [records] to CSP650 in a chosen later
/// semester, one by one, and reports which ones could not be promoted and why
/// (most often: marks not finalized, or not passed).
class HandoverCohortDialog extends ConsumerStatefulWidget {
  const HandoverCohortDialog({super.key, required this.records});

  final List<FypRecord> records;

  @override
  ConsumerState<HandoverCohortDialog> createState() => _HandoverCohortDialogState();
}

class _HandoverCohortDialogState extends ConsumerState<HandoverCohortDialog> {
  String? _target;
  bool _busy = false;
  int _done = 0;
  final List<String> _problems = [];
  int? _promoted;

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _done = 0;
      _problems.clear();
      _promoted = null;
    });
    var promoted = 0;
    final admin = ref.read(semesterAdminProvider);
    for (final r in widget.records) {
      try {
        await admin.promote(r.id, _target!);
        promoted++;
      } catch (e) {
        _problems.add('${r.projectTitle ?? r.matricId ?? 'A record'}: ${friendlyError(e)}');
      }
      if (!mounted) return;
      setState(() => _done++);
    }
    ref.invalidate(fypRecordsProvider);
    if (mounted) {
      setState(() {
        _busy = false;
        _promoted = promoted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final semesters = ref.watch(fypmsSemestersProvider).value ?? const <AcademicSemester>[];
    final currentIds = {for (final r in widget.records) r.academicSemesterId};
    final latestCurrent = semesters
        .where((s) => currentIds.contains(s.id))
        .fold<AcademicSemester?>(null, (a, s) => a == null || s.startDate.isAfter(a.startDate) ? s : a);
    final options = [
      for (final s in semesters)
        if ((s.status == 'planned' || s.status == 'active') &&
            (latestCurrent == null || s.startDate.isAfter(latestCurrent.startDate)))
          s,
    ];
    final finished = _promoted != null;
    return AlertDialog(
      title: const Text('Hand Over Cohort to CSP650'),
      content: SizedBox(
        width: dialogWidth(context, 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creates a CSP650 record in the chosen semester for each of the ${widget.records.length} '
                'CSP600 ${widget.records.length == 1 ? 'student' : 'students'} whose marks are finalized and '
                'passed. Students who are not ready are skipped and listed below.',
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              DropdownButtonFormField<String>(
                key: const Key('handover-semester'),
                initialValue: _target,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'CSP650 semester'),
                items: [for (final s in options) DropdownMenuItem(value: s.id, child: Text('${s.code} — ${s.label}'))],
                onChanged: _busy || finished ? null : (v) => setState(() => _target = v),
              ),
              if (options.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                  child: Text(
                    'Ask the coordinator to create the next semester first (Semesters & Courses).',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
                  ),
                ),
              if (_busy || finished) ...[
                const SizedBox(height: DesignSystem.spaceMd),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    finished
                        ? '$_promoted promoted, ${_problems.length} not promoted.'
                        : 'Promoting $_done of ${widget.records.length}…',
                    key: const Key('handover-progress'),
                    style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (_busy) ...[
                  const SizedBox(height: DesignSystem.spaceXs),
                  LinearProgressIndicator(value: widget.records.isEmpty ? null : _done / widget.records.length),
                ],
              ],
              for (final p in _problems)
                Padding(
                  padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                  child: Text('• $p', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(finished ? 'Close' : 'Cancel'),
        ),
        if (!finished)
          BusyButton(
            label: 'Hand Over',
            busyLabel: 'Handing over…',
            busy: _busy,
            onPressed: _target == null ? null : _run,
          ),
      ],
    );
  }
}
