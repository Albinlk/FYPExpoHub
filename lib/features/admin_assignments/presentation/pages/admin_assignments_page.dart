import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/domain/models/project_lecturer_assignment.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../domain/assignment_matching.dart';

/// G-07: who supervises / examines which project. Lecturers can only mark
/// visits for projects they are assigned to, so this is what makes
/// "My Visits" work. Assignments can be matched in bulk from the names on
/// the projects, or added and removed one by one.
class AdminAssignmentsPage extends ConsumerStatefulWidget {
  const AdminAssignmentsPage({super.key});

  @override
  ConsumerState<AdminAssignmentsPage> createState() => _AdminAssignmentsPageState();
}

class _AdminAssignmentsPageState extends ConsumerState<AdminAssignmentsPage> {
  final _search = TextEditingController();
  bool _busy = false;

  static const _pageSize = 40;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Resolves each project's event (slug or id) to its uuid, once per event.
  Future<List<Map<String, dynamic>>> _rows(List<(Project, LecturerRef, String)> items) async {
    final db = ref.read(supabaseDbServiceProvider);
    final uid = ref.read(currentAuthUserProvider)?.id;
    final events = <String, String>{};
    return [
      for (final (p, l, role) in items)
        assignmentRow(
          eventId: events[p.eventId] ??= await db.resolveEventId(p.eventId),
          projectId: p.id,
          lecturer: l,
          role: role,
          assignedBy: uid,
        ),
    ];
  }

  Future<void> _write(Future<void> Function() write, String success) async {
    setState(() => _busy = true);
    await runAdminWrite(context, () async {
      await write();
      ref.invalidate(allAssignmentsProvider);
    }, success: success);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _applyMatches(List<ProposedAssignment> proposals) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create assignments'),
        content: Text(
          'Create ${proposals.length} assignments from the supervisor and examiner names on the projects? '
          'Those lecturers can then mark visits for these projects.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true) return;
    await _write(
      () async => ref
          .read(supabaseDbServiceProvider)
          .upsertAssignmentsByKey(await _rows([for (final m in proposals) (m.project, m.lecturer, m.role)])),
      '${proposals.length} assignments created.',
    );
  }

  Future<void> _assign(Project project, List<LecturerRef> lecturers) async {
    final picked = await showDialog<(LecturerRef, String)>(
      context: context,
      builder: (_) => _AssignDialog(project: project, lecturers: lecturers),
    );
    if (picked == null) return;
    final (lecturer, role) = picked;
    await _write(
      () async => ref.read(supabaseDbServiceProvider).upsertAssignmentsByKey(await _rows([(project, lecturer, role)])),
      '${lecturer.name} assigned as $role.',
    );
  }

  Future<void> _remove(ProjectLecturerAssignment a) async {
    final ok = await confirmAction(
      context,
      title: 'Remove assignment',
      message: 'Remove ${a.lecturerDisplayName} as ${a.role}? Visits already recorded are kept.',
      confirmLabel: 'Remove',
    );
    if (!ok) return;
    await _write(() => ref.read(supabaseDbServiceProvider).removeAssignment(a.id), 'Assignment removed.');
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final assignmentsAsync = ref.watch(allAssignmentsProvider);
    final lecturers = [
      for (final m in ref.watch(allLecturersProvider).value ?? const <Map<String, dynamic>>[])
        ?LecturerRef.fromRow(m),
    ];
    final assignments = assignmentsAsync.value ?? const <ProjectLecturerAssignment>[];
    final match = proposeAssignments(projects: projects, lecturers: lecturers, existing: assignments);
    final byProject = <String, List<ProjectLecturerAssignment>>{};
    for (final a in assignments) {
      if (a.status == 'active') byProject.putIfAbsent(a.projectId, () => []).add(a);
    }
    final q = _search.text.trim().toLowerCase();
    final filtered = [
      for (final p in projects)
        if (q.isEmpty ||
            p.title.toLowerCase().contains(q) ||
            p.supervisorDisplayName.toLowerCase().contains(q) ||
            (p.examinerDisplayName ?? '').toLowerCase().contains(q) ||
            (p.boothNumber ?? '').toLowerCase() == q)
          p,
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        children: [
          Text('Lecturer Assignments', style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
          const SizedBox(height: 4),
          Text(
            'Lecturers can mark visits only for projects they are assigned to. '
            '${byProject.values.fold<int>(0, (n, l) => n + l.length)} active assignments across ${byProject.length} projects.',
            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          Card(
            color: DesignSystem.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Match from project names', style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${match.proposals.length} new assignments match an active lecturer account by name. '
                    '${match.unmatchedNames.length} names on projects have no lecturer account'
                    '${match.ambiguousNames.isEmpty ? '' : ', ${match.ambiguousNames.length} match more than one'}.',
                    key: const Key('match-summary'),
                    style: DesignSystem.bodySm,
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  FilledButton.icon(
                    key: const Key('apply-matches'),
                    onPressed: _busy || match.proposals.isEmpty ? null : () => _applyMatches(match.proposals),
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    label: Text('Create ${match.proposals.length} assignments'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          TextField(
            key: const Key('assignment-search'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search project, lecturer or booth',
            ),
          ),
          const SizedBox(height: DesignSystem.spaceSm),
          if (assignmentsAsync.isLoading && assignments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(DesignSystem.spaceLg),
              child: Center(child: CircularProgressIndicator()),
            ),
          for (final p in filtered.take(_pageSize))
            Card(
              margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.boothNumber == null ? '' : '${p.boothNumber} · '}${p.title}',
                      style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'SV: ${p.supervisorDisplayName.isEmpty ? '—' : p.supervisorDisplayName}'
                      ' · EX: ${(p.examinerDisplayName ?? '').isEmpty ? '—' : p.examinerDisplayName}',
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: DesignSystem.spaceXs,
                      runSpacing: DesignSystem.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final a in byProject[p.id] ?? const <ProjectLecturerAssignment>[])
                          InputChip(
                            label: Text('${a.role == 'supervisor' ? 'SV' : 'EX'} · ${a.lecturerDisplayName}'),
                            onDeleted: _busy ? null : () => _remove(a),
                            deleteButtonTooltipMessage: 'Remove assignment',
                          ),
                        TextButton.icon(
                          onPressed: _busy || lecturers.isEmpty ? null : () => _assign(p, lecturers),
                          icon: const Icon(Icons.person_add_alt, size: 18),
                          label: const Text('Assign'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (filtered.length > _pageSize)
            Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceSm),
              child: Text(
                'Showing $_pageSize of ${filtered.length} projects — search to narrow down.',
                textAlign: TextAlign.center,
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
            ),
          if (lecturers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceSm),
              child: Text(
                'No active lecturer accounts yet — add them under Lecturer Management first.',
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignDialog extends StatefulWidget {
  const _AssignDialog({required this.project, required this.lecturers});

  final Project project;
  final List<LecturerRef> lecturers;

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  LecturerRef? _lecturer;
  String _role = 'supervisor';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign lecturer'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.project.title, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: DesignSystem.spaceSm),
            DropdownButtonFormField<String>(
              key: const Key('assign-lecturer'),
              initialValue: _lecturer?.id,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Lecturer'),
              items: [
                for (final l in widget.lecturers)
                  DropdownMenuItem(value: l.id, child: Text(l.name, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (id) => setState(() => _lecturer = widget.lecturers.firstWhere((l) => l.id == id)),
            ),
            DropdownButtonFormField<String>(
              key: const Key('assign-role'),
              initialValue: _role,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                DropdownMenuItem(value: 'examiner', child: Text('Examiner')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'supervisor'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _lecturer == null ? null : () => Navigator.pop(context, (_lecturer!, _role)),
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
