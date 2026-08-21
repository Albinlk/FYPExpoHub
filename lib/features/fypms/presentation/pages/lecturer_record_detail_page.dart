import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class LecturerRecordDetailPage extends ConsumerWidget {
  final String recordId;

  const LecturerRecordDetailPage({super.key, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(fypRecordsProvider);
    final assignments = ref.watch(fypRecordAssignmentsProvider(recordId));

    return records.when(
      loading: () => const FypmsLoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        final record = list.where((r) => r.id == recordId).firstOrNull;
        if (record == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 64, color: DesignSystem.onSurfaceVariant),
                const SizedBox(height: DesignSystem.spaceMd),
                Text('Record not found', style: DesignSystem.h3),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: DesignSystem.background,
          appBar: AppBar(
            backgroundColor: DesignSystem.primary,
            title: Text(
              record.projectTitle ?? 'Record Details',
              style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              _Row(label: 'Course', value: record.currentCourseCode),
              _Row(label: 'Programme', value: record.programmeCode),
              _Row(label: 'Status', value: record.workflowStatus.replaceAll('_', ' ')),
              _Row(label: 'Matric ID', value: record.matricId ?? '—'),
              _Row(label: 'Description', value: record.projectDescription ?? '—'),
              const SizedBox(height: DesignSystem.spaceMd),
              Text('Assignments', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
              const SizedBox(height: DesignSystem.spaceSm),
              assignments.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(DesignSystem.spaceSm),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Text('Error loading assignments', style: DesignSystem.bodySm),
                data: (items) => items.isEmpty
                    ? Text('No active assignments.', style: DesignSystem.bodySm)
                    : Column(
                        children: [
                          for (final a in items)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Icon(
                                a.academicRole == 'examiner' ? Icons.rate_review : Icons.supervisor_account,
                                color: DesignSystem.primary,
                              ),
                              title: Text(a.academicRole.replaceAll('_', ' '), style: DesignSystem.bodySm),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: DesignSystem.bodySm)),
        ],
      ),
    );
  }
}