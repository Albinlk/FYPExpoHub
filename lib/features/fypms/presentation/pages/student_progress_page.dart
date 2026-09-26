import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_attendance.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/consultation_attendance_banner.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

/// F5 Proposal/Project In-Progress Form: one entry per supervision meeting
/// (date, completed activity, next activity), signed by the supervisor, with
/// attendance against the 80 % requirement.
class StudentProgressPage extends ConsumerWidget {
  const StudentProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Consultation Log',
      builder: (context, ref, record) {
        final logs = ref.watch(fypProgressLogsProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Consultation Log (F5)', style: DesignSystem.h2)),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => ConsultationLogDialog(record: record),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Log Meeting'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (logs.value != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(DesignSystem.gutter, 0, DesignSystem.gutter, DesignSystem.spaceSm),
                child: ConsultationAttendanceBanner(record: record, logs: logs.value!),
              ),
            Expanded(
              child: logs.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No consultations logged yet.\nLog each meeting with your supervisor.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      final log = items[itemIndex];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                        color: DesignSystem.surfaceContainerLowest,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                          leading: const Icon(Icons.forum, size: 36, color: DesignSystem.primary),
                          title: Text(
                            '${formatFypDate(log.progressDate)} · Week ${log.weekNumber}',
                            style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                switch (log.status) {
                                  'validated' => 'Signed by supervisor',
                                  'rejected' => 'Not accepted by supervisor',
                                  'submitted' => 'Awaiting supervisor signature',
                                  _ => log.status,
                                },
                                style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: DesignSystem.spaceXs),
                              Text('Completed: ${log.summary}', style: DesignSystem.bodySm),
                              if (log.nextPlan?.isNotEmpty == true)
                                Text('Next: ${log.nextPlan}', style: DesignSystem.bodySm),
                              if (log.challenges?.isNotEmpty == true)
                                Text(
                                  'Challenges: ${log.challenges}',
                                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                ),
                              if (log.validationComment?.isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                  child: Text(
                                    'Supervisor: ${log.validationComment}',
                                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.secondary),
                                  ),
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

/// One F5 entry: meeting date (within the semester, not in the future),
/// completed activity (required), next activity, challenges.
class ConsultationLogDialog extends ConsumerStatefulWidget {
  const ConsultationLogDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<ConsultationLogDialog> createState() => _ConsultationLogDialogState();
}

class _ConsultationLogDialogState extends ConsumerState<ConsultationLogDialog> {
  final _completed = TextEditingController();
  final _next = TextEditingController();
  final _challenges = TextEditingController();
  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _completed.dispose();
    _next.dispose();
    _challenges.dispose();
    super.dispose();
  }

  String? _trimmed(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _pickDate(DateTime first, DateTime last) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(last) ? last : (_date.isBefore(first) ? first : _date),
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit(DateTime? semesterStart) async {
    setState(() => _submitting = true);
    try {
      await ref.read(supabaseRpcServiceProvider).submitProgressLog(
            fypRecordId: widget.record.id,
            // The server derives the week from the semester start; this is its
            // fallback when the semester has no dates.
            weekNumber: semesterStart == null ? 1 : semesterWeek(semesterStart, _date).clamp(1, 52),
            summary: _completed.text.trim(),
            nextPlan: _trimmed(_next),
            challenges: _trimmed(_challenges),
            progressDate: _date,
          );
      ref.invalidate(fypProgressLogsProvider(widget.record.id));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Consultation logged for your supervisor to sign.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to log: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final semester = ref
        .watch(fypmsSemestersProvider)
        .value
        ?.where((s) => s.id == widget.record.academicSemesterId)
        .firstOrNull;
    final today = DateTime.now();
    final first = semester?.startDate ?? DateTime(today.year - 1);
    final last = semester == null || semester.endDate.isAfter(today) ? today : semester.endDate;
    final ready = _completed.text.trim().isNotEmpty && !_submitting;

    return AlertDialog(
      title: Text(
        'Log Consultation (F5)',
        style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg).copyWith(color: DesignSystem.primary),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                key: const Key('meeting-date'),
                onTap: _submitting ? null : () => _pickDate(first, last),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of meeting',
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Text(
                    semester == null
                        ? formatFypDate(_date)
                        : '${formatFypDate(_date)} · Week ${semesterWeek(semester.startDate, _date)}',
                  ),
                ),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                key: const Key('completed-activity'),
                controller: _completed,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Completed activity *'),
                maxLines: 3,
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                controller: _next,
                decoration: const InputDecoration(labelText: 'Next activity'),
                maxLines: 2,
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                controller: _challenges,
                decoration: const InputDecoration(labelText: 'Challenges (optional)'),
                maxLines: 2,
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
          onPressed: ready ? () => _submit(semester?.startDate) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.secondary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
