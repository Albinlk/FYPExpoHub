import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/domain/models/fypms/fyp_report_submission.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import 'student_reports_page.dart' show ReportSubmissionCard;

/// F6 endorsement: the supervisor checks the report and its plagiarism report
/// (similarity <= 30 %) and endorses it for review, or returns it.
class SupervisorReportsPage extends ConsumerWidget {
  const SupervisorReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only records this lecturer supervises or co-supervises can be endorsed.
    final main = ref.watch(assignedFypRecordsProvider('supervisor'));
    final co = ref.watch(assignedFypRecordsProvider('co_supervisor'));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Report Endorsement',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: main.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (mainRecords) {
          final records = <String, FypRecord>{
            for (final r in mainRecords) r.id: r,
            for (final r in co.value ?? const <FypRecord>[]) r.id: r,
          }.values.toList();
          if (records.isEmpty) {
            return const Center(child: Text('No students are assigned to you yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: records.length,
            itemBuilder: (context, index) => _RecordReports(record: records[index]),
          );
        },
      ),
    );
  }
}

class _RecordReports extends ConsumerWidget {
  const _RecordReports({required this.record});

  final FypRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(fypReportSubmissionsProvider(record.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceSm),
          child: Text(
            record.projectTitle ?? 'Untitled Project',
            style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
          ),
        ),
        reports.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  child: Text('No reports submitted yet.', style: DesignSystem.bodySm),
                )
              : Column(
                  children: [
                    for (final r in list)
                      ReportSubmissionCard(
                        report: r,
                        actions: r.status == 'submitted' ? _EndorseActions(report: r) : null,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: DesignSystem.spaceMd),
      ],
    );
  }
}

class _EndorseActions extends ConsumerStatefulWidget {
  const _EndorseActions({required this.report});

  final FypReportSubmission report;

  @override
  ConsumerState<_EndorseActions> createState() => _EndorseActionsState();
}

class _EndorseActionsState extends ConsumerState<_EndorseActions> {
  final _comment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _decide(String decision) async {
    final comment = _comment.text.trim();
    if (decision == 'returned' && comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Say why the report is returned.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(endorseReportProvider)(
        widget.report.id,
        decision,
        comment.isEmpty ? null : comment,
        widget.report.fypRecordId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decision == 'endorsed' ? 'Report endorsed.' : 'Report returned to the student.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DesignSystem.spaceSm),
        TextField(
          controller: _comment,
          decoration: const InputDecoration(labelText: 'Comment (required to return)'),
        ),
        const SizedBox(height: DesignSystem.spaceSm),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: DesignSystem.spaceSm,
          runSpacing: DesignSystem.spaceSm,
          children: [
            OutlinedButton(
              onPressed: _busy ? null : () => _decide('returned'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignSystem.error,
                side: const BorderSide(color: DesignSystem.error),
              ),
              child: const Text('Return'),
            ),
            FilledButton(
              onPressed: _busy ? null : () => _decide('endorsed'),
              child: const Text('Endorse'),
            ),
          ],
        ),
      ],
    );
  }
}
