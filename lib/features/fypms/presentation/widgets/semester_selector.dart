import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/academic_semester.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/layout/responsive.dart';

/// App-bar dropdown choosing which semester staff lists show (backlog S2):
/// the active semester by default, any other semester, or all of them.
class SemesterSelector extends ConsumerWidget {
  const SemesterSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(fypmsSemestersProvider).value ?? const <AcademicSemester>[];
    if (semesters.isEmpty) return const SizedBox.shrink();
    final selected = ref.watch(fypmsSelectedSemesterProvider);
    final active = activeSemesterOf(semesters);
    final value = selected ?? active?.id ?? kAllSemesters;
    final sorted = [...semesters]..sort((a, b) => b.startDate.compareTo(a.startDate));
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        key: const Key('semester-selector'),
        value: value,
        dropdownColor: DesignSystem.primaryContainer,
        iconEnabledColor: Colors.white,
        style: DesignSystem.bodySm.copyWith(color: Colors.white),
        items: [
          for (final s in sorted)
            DropdownMenuItem(
              value: s.id,
              child: Text('${s.code}${s.status == 'active' ? ' · active' : s.status == 'archived' ? ' · archived' : ''}'),
            ),
          const DropdownMenuItem(value: kAllSemesters, child: Text('All semesters')),
        ],
        onChanged: (v) => ref
            .read(fypmsSelectedSemesterProvider.notifier)
            // Choosing the active semester goes back to "follow the active one".
            .select(v == active?.id ? null : v),
      ),
    );
  }
}

/// Coordinator / CSP600 lecturer: promote a CSP600 record to CSP650 in a
/// later semester (backlog S3).
class PromoteRecordDialog extends ConsumerStatefulWidget {
  const PromoteRecordDialog({super.key, required this.fypRecordId, required this.currentSemesterId, required this.title});

  final String fypRecordId;
  final String currentSemesterId;
  final String title;

  @override
  ConsumerState<PromoteRecordDialog> createState() => _PromoteRecordDialogState();
}

class _PromoteRecordDialogState extends ConsumerState<PromoteRecordDialog> {
  String? _target;
  bool _busy = false;

  Future<void> _promote() async {
    setState(() => _busy = true);
    try {
      await ref.read(semesterAdminProvider).promote(widget.fypRecordId, _target!);
      if (!mounted) return;
      final m = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      m.showSnackBar(const SnackBar(content: Text('CSP650 record created.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final semesters = ref.watch(fypmsSemestersProvider).value ?? const <AcademicSemester>[];
    final current = semesters.where((s) => s.id == widget.currentSemesterId).firstOrNull;
    final options = [
      for (final s in semesters)
        if ((s.status == 'planned' || s.status == 'active') && (current == null || s.startDate.isAfter(current.startDate))) s,
    ];
    return AlertDialog(
      title: const Text('Promote to CSP650'),
      content: SizedBox(
        width: dialogWidth(context, 420),
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            Text(
              'Creates the student\'s CSP650 record in the chosen semester, linked to this one, with the same '
              'title, supervisor, co-supervisor and examiner. CSP600 marks must be finalized and passed.',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            DropdownButtonFormField<String>(
              key: const Key('promote-semester'),
              initialValue: _target,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'CSP650 semester'),
              items: [for (final s in options) DropdownMenuItem(value: s.id, child: Text('${s.code} — ${s.label}'))],
              onChanged: (v) => setState(() => _target = v),
            ),
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Create the next semester first (Semesters & Courses).',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
                ),
              ),
          ],
        )),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _target == null || _busy ? null : _promote, child: const Text('Promote')),
      ],
    );
  }
}
