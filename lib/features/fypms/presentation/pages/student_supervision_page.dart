import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/supervisor_change_widgets.dart';
import '../widgets/student_record_workspace.dart';

/// F1 Mutual Acceptance: the student names the supervisor (and co-supervisor)
/// who agreed to supervise them and the project area and title; the
/// supervisor accepts or declines.
class StudentSupervisionPage extends ConsumerWidget {
  const StudentSupervisionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Supervision Requests',
      builder: (context, ref, record) {
        final requests = ref.watch(fypSupervisionRequestsProvider(record.id));
        final directory = ref.watch(supervisorsDirectoryProvider);
        final hasPending = requests.value?.any((r) => r.status == 'pending') ?? false;
        final hasSupervisor = record.mainSupervisorId != null;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Supervision Requests', style: DesignSystem.h2)),
                  if (!hasPending && !hasSupervisor)
                    FilledButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => _F1RequestDialog(record: record),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('New Request'),
                      style: FilledButton.styleFrom(
                        backgroundColor: DesignSystem.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            // R11: a supervisor change goes to the coordinator (F1 terms).
            if (hasSupervisor) SupervisorChangeSection(record: record),
            Expanded(
              child: requests.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No supervision requests yet.\nSubmit your F1 once a supervisor has agreed to supervise you.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final nameById = <String, String>{
                    for (final s in directory.asData?.value ?? [])
                      if (s['id'] is String) s['id'] as String: (s['display_name'] as String? ?? ''),
                  };
                  String nameOf(String id) => nameById[id] ?? 'Staff member';
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      final req = items[itemIndex];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                        color: DesignSystem.surfaceContainerLowest,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                          leading: const Icon(Icons.supervisor_account, size: 40, color: DesignSystem.primary),
                          title: Text(
                            req.projectTitle ?? 'Status: ${req.status.replaceAll('_', ' ')}',
                            style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${req.status.replaceAll('_', ' ')}', style: DesignSystem.bodySm),
                              if (req.projectArea?.isNotEmpty == true)
                                Text('Area: ${req.projectArea}', style: DesignSystem.bodySm),
                              if (req.preferredSupervisorId != null)
                                Text('Supervisor: ${nameOf(req.preferredSupervisorId!)}', style: DesignSystem.bodySm),
                              if (req.preferredCoSupervisorId != null)
                                Text('Co-supervisor: ${nameOf(req.preferredCoSupervisorId!)}', style: DesignSystem.bodySm),
                              if (req.rationale?.isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                  child: Text(req.rationale!, style: DesignSystem.bodySm),
                                ),
                              if (req.decisionReason?.isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                  child: Text(
                                    'Decision: ${req.decisionReason}',
                                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                  ),
                                ),
                              const SizedBox(height: DesignSystem.spaceSm),
                              Text(
                                'Submitted ${formatFypDate(req.createdAt)}',
                                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// F1 form: supervisor (required), co-supervisor (optional, different),
/// project area and title (required), rationale.
class _F1RequestDialog extends ConsumerStatefulWidget {
  const _F1RequestDialog({required this.record});

  final FypRecord record;

  @override
  ConsumerState<_F1RequestDialog> createState() => _F1RequestDialogState();
}

class _F1RequestDialogState extends ConsumerState<_F1RequestDialog> {
  final _area = TextEditingController();
  late final _title = TextEditingController(text: widget.record.projectTitle ?? '');
  final _rationale = TextEditingController();
  String? _supervisorId;
  String? _coSupervisorId;
  bool _submitting = false;

  @override
  void dispose() {
    _area.dispose();
    _title.dispose();
    _rationale.dispose();
    super.dispose();
  }

  String? _trimmed(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(supabaseRpcServiceProvider).submitSupervisionRequest(
            fypRecordId: widget.record.id,
            preferredSupervisorId: _supervisorId,
            preferredCoSupervisorId: _coSupervisorId,
            projectArea: _trimmed(_area),
            projectTitle: _trimmed(_title),
            rationale: _trimmed(_rationale),
          );
      ref.invalidate(fypSupervisionRequestsProvider(widget.record.id));
      ref.invalidate(myFypRecordsProvider);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('F1 submitted to your supervisor.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final directory = ref.watch(supervisorsDirectoryProvider);
    final ready = _supervisorId != null && _trimmed(_title) != null && !_submitting;

    return AlertDialog(
      title: Text(
        'F1 — Mutual Acceptance',
        style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg).copyWith(color: DesignSystem.primary),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Name the lecturer who agreed to supervise you. They accept or decline this request.',
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              directory.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(DesignSystem.spaceMd),
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text(
                  'Could not load supervisors: $e',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
                ),
                data: (staff) {
                  String role(Map<String, dynamic> s) => s['role_code'] as String? ?? 'supervisor';
                  final supervisors = [for (final s in staff) if (role(s) == 'supervisor') s];
                  final coSupervisors = [
                    for (final s in staff)
                      if ((role(s) == 'supervisor' || role(s) == 'co_supervisor') && s['id'] != _supervisorId) s,
                  ];
                  DropdownMenuItem<String> item(Map<String, dynamic> s) => DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text(s['display_name'] as String? ?? 'Supervisor', overflow: TextOverflow.ellipsis),
                      );
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        key: const Key('f1-supervisor'),
                        initialValue: _supervisorId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Supervisor *',
                          prefixIcon: Icon(Icons.supervisor_account),
                        ),
                        items: [for (final s in supervisors) item(s)],
                        onChanged: (v) => setState(() {
                          _supervisorId = v;
                          if (_coSupervisorId == v) _coSupervisorId = null;
                        }),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      DropdownButtonFormField<String?>(
                        key: ValueKey('f1-co-supervisor-$_supervisorId'),
                        initialValue: _coSupervisorId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Co-supervisor (if any)',
                          prefixIcon: Icon(Icons.group),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('None')),
                          for (final s in coSupervisors)
                            DropdownMenuItem<String?>(
                              value: s['id'] as String,
                              child: Text(s['display_name'] as String? ?? 'Co-supervisor', overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (v) => setState(() => _coSupervisorId = v),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                key: const Key('f1-area'),
                controller: _area,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Project area', counterText: ''),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                key: const Key('f1-title'),
                controller: _title,
                maxLength: 300,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Project title *', counterText: ''),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                controller: _rationale,
                decoration: const InputDecoration(labelText: 'Rationale / notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: ready ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.secondary,
            foregroundColor: Colors.white,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
