import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_milestone.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/milestone_extension_widgets.dart';
import '../../../../core/widgets/async_state.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/widgets/busy_button.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/layout/responsive.dart';

class CspMilestonesPage extends ConsumerStatefulWidget {
  const CspMilestonesPage({super.key});

  @override
  ConsumerState<CspMilestonesPage> createState() => _CspMilestonesPageState();
}

class _CspMilestonesPageState extends ConsumerState<CspMilestonesPage> {
  String? _selectedRecordId;

  @override
  Widget build(BuildContext context) {
    // CSP lecturers manage milestones per FYP record; a selector lets them
    // pick which record's milestone set they are editing.
    final records = ref.watch(cspRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.surfaceContainerLowest,
        foregroundColor: DesignSystem.primary,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: DesignSystem.outlineVariant)),
        title: Text(
          'Milestones',
          style: DesignSystem.h3.copyWith(
            color: DesignSystem.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypRecordsProvider), what: 'this page'),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No records found to manage milestones.'),
            );
          }
          final selectedId = _selectedRecordId ?? list.first.id;
          final selected =
              list.firstWhere((r) => r.id == selectedId, orElse: () => list.first);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignSystem.gutter, DesignSystem.spaceSm, DesignSystem.gutter, 0),
                child: Row(
                  children: [
                    Text('Record: ', style: DesignSystem.bodyMd),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selected.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                        ),
                        items: [
                          for (final r in list)
                            DropdownMenuItem(
                              value: r.id,
                              child: Text(
                                '${r.projectTitle ?? 'Untitled'} (${r.currentCourseCode})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _selectedRecordId = v),
                      ),
                    ),
                  ],
                ),
              ),
              ExtensionRequestsPanel(fypRecordId: selected.id),
              Expanded(
                child: _MilestonesList(
                  recordId: selected.id,
                  // Same course only: CSP600 and CSP650 have different milestones.
                  others: [for (final r in list) if (r.id != selected.id && r.currentCourseCode == selected.currentCourseCode) r],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MilestonesList extends ConsumerWidget {
  final String recordId;
  final List<FypRecord> others;

  const _MilestonesList({required this.recordId, this.others = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(fypMilestonesProvider(recordId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Milestones', style: DesignSystem.h2)),
              Wrap(
                spacing: DesignSystem.spaceSm,
                children: [
                  // The handbook sets no week-by-week timeline, so a lecturer
                  // sets one student's milestones and copies them to the rest.
                  OutlinedButton.icon(
                    key: const Key('copy-milestones'),
                    onPressed: others.isEmpty || (milestones.value?.isEmpty ?? true)
                        ? null
                        : () => showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => CopyMilestonesDialog(
                                milestones: milestones.requireValue,
                                targets: others,
                              ),
                            ),
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('Copy to All Students'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showMilestoneDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: milestones.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypMilestonesProvider(recordId)), what: 'this page'),
            data: (list) {
              if (list.isEmpty) {
                return const Center(child: Text('No milestones defined.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.gutter,
                ),
                itemCount: list.length,
                itemBuilder: (context, itemIndex) {
                  final m = list[itemIndex];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(
                        bottom: DesignSystem.spaceMd,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignSystem.radiusXl,
                      ),
                      color: DesignSystem.surfaceContainerLowest,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(
                          DesignSystem.spaceMd,
                        ),
                        leading: const Icon(
                          Icons.flag,
                          color: DesignSystem.primary,
                        ),
                        title: Text(
                          '${m.milestoneCode} — ${m.milestoneTitle}',
                          style: DesignSystem.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Target: ${m.targetDate != null ? formatFypDate(m.targetDate!) : 'TBD'}',
                          style: DesignSystem.bodySm,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FypStatusBadge.milestone(m.status),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: 'Edit milestone',
                              onPressed: () =>
                                  _showMilestoneDialog(context, ref, m),
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
  }

  void _showMilestoneDialog(
    BuildContext context,
    WidgetRef ref, [
    FypMilestone? milestone,
  ]) {
    final codeController = TextEditingController(
      text: milestone?.milestoneCode,
    );
    final titleController = TextEditingController(
      text: milestone?.milestoneTitle,
    );
    final descController = TextEditingController(text: milestone?.description);
    DateTime selectedDate = milestone?.targetDate ?? DateTime.now();
    String status = milestone?.status ?? 'pending';
    var busy = false;
    String? error;

    showDialog<void>(
      context: context,
      // A stray tap outside must not discard what was typed.
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text(
                milestone == null ? 'New Milestone' : 'Edit Milestone',
                style: DesignSystem.h2,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: codeController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Milestone Code',
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: titleController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Target Date: ${formatFypDate(selectedDate)}',
                        style: DesignSystem.bodySm,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        tooltip: 'Pick target date',
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'overdue',
                          child: Text('Overdue'),
                        ),
                      ],
                      onChanged: busy ? null : (v) => setState(() => status = v!),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: DesignSystem.spaceSm),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          error!,
                          style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                BusyButton(
                  label: 'Save',
                  busyLabel: 'Saving…',
                  busy: busy,
                  onPressed:
                      codeController.text.trim().isEmpty ||
                          titleController.text.trim().isEmpty
                      ? null
                      : () async {
                          setState(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            final rpc = ref.read(supabaseRpcServiceProvider);
                            await rpc.createOrUpdateMilestone(
                              fypRecordId: recordId,
                              milestoneCode: codeController.text.trim(),
                              milestoneTitle: titleController.text.trim(),
                              description: descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim(),
                              targetDate: selectedDate,
                              status: status,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            ref.invalidate(fypMilestonesProvider(recordId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Milestone saved.'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setState(() {
                                busy = false;
                                error = 'Could not save the milestone: ${friendlyError(e)}';
                              });
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Copies one student's milestones (code, title, description, target date) to
/// other records of the same course, as "pending". Existing milestones with the
/// same code are updated, so running it again is safe.
class CopyMilestonesDialog extends ConsumerStatefulWidget {
  const CopyMilestonesDialog({super.key, required this.milestones, required this.targets});

  final List<FypMilestone> milestones;
  final List<FypRecord> targets;

  @override
  ConsumerState<CopyMilestonesDialog> createState() => _CopyMilestonesDialogState();
}

class _CopyMilestonesDialogState extends ConsumerState<CopyMilestonesDialog> {
  bool _busy = false;
  int _done = 0;
  bool _finished = false;
  final List<String> _problems = [];

  Future<void> _copy() async {
    setState(() {
      _busy = true;
      _done = 0;
      _problems.clear();
    });
    final rpc = ref.read(supabaseRpcServiceProvider);
    for (final record in widget.targets) {
      try {
        for (final m in widget.milestones) {
          await rpc.createOrUpdateMilestone(
            fypRecordId: record.id,
            milestoneCode: m.milestoneCode,
            milestoneTitle: m.milestoneTitle,
            description: m.description,
            targetDate: m.targetDate,
            status: 'pending',
          );
        }
      } catch (e) {
        _problems.add('${record.projectTitle ?? record.matricId ?? 'A record'}: ${friendlyError(e)}');
      }
      if (!mounted) return;
      setState(() => _done++);
      ref.invalidate(fypMilestonesProvider(record.id));
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _finished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.targets.length;
    return AlertDialog(
      title: const Text('Copy Milestones to All Students'),
      content: SizedBox(
        width: dialogWidth(context, 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Copies these ${widget.milestones.length} milestones to the other $n '
                '${n == 1 ? 'student' : 'students'} in this course. A milestone with the same code is '
                'updated rather than duplicated.',
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              for (final m in widget.milestones)
                Text(
                  '• ${m.milestoneCode} — ${m.milestoneTitle}'
                  '${m.targetDate == null ? '' : ' (${formatFypDate(m.targetDate!)})'}',
                  style: DesignSystem.bodySm,
                ),
              if (_busy || _finished) ...[
                const SizedBox(height: DesignSystem.spaceMd),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _finished
                        ? '${n - _problems.length} of $n students updated.'
                        : 'Copying to student $_done of $n…',
                    key: const Key('copy-milestones-progress'),
                    style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              for (final p in _problems)
                Text('• $p', style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(_finished ? 'Close' : 'Cancel'),
        ),
        if (!_finished)
          BusyButton(label: 'Copy Milestones', busyLabel: 'Copying…', busy: _busy, onPressed: _copy),
      ],
    );
  }
}
