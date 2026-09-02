import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/fypms_loading_widget.dart';

class StudentRecordDetailPage extends ConsumerWidget {
  final String recordId;

  const StudentRecordDetailPage({super.key, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(myFypRecordsProvider);
    final assignments = ref.watch(fypRecordAssignmentsProvider(recordId));
    final directory = ref.watch(supervisorsDirectoryProvider);

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

        // Resolve staff display names from the public directory (id + name +
        // role); fall back gracefully while it loads.
        final nameById = <String, String>{
          for (final s in directory.asData?.value ?? [])
            if (s['id'] is String) s['id'] as String: (s['display_name'] as String? ?? ''),
        };
        String staffName(String? id) =>
            id == null ? 'Not assigned' : (nameById[id] ?? 'Staff member');

        return Scaffold(
          backgroundColor: DesignSystem.background,
          appBar: AppBar(
            backgroundColor: DesignSystem.primary,
            title: Text(
              'Record Details',
              style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              _Section(
                title: 'Project Information',
                children: [
                  _InfoRow(label: 'Title', value: record.projectTitle ?? '—'),
                  _InfoRow(label: 'Description', value: record.projectDescription ?? '—'),
                  _InfoRow(label: 'Project Type', value: record.projectType ?? '—'),
                  _InfoRow(label: 'Industry Partner', value: record.externalIndustryPartner ?? '—'),
                ],
              ),
              _Section(
                title: 'Academic Details',
                children: [
                  _InfoRow(label: 'Course', value: record.currentCourseCode),
                  _InfoRow(label: 'Programme', value: record.programmeCode),
                  _InfoRow(label: 'Matric ID', value: record.matricId ?? '—'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text('Workflow Status', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: FypStatusBadge.workflow(record.workflowStatus)),
                      ],
                    ),
                  ),
                ],
              ),
              _Section(
                title: 'Supervisors & Examiner',
                children: [
                  _InfoRow(label: 'Main Supervisor', value: staffName(record.mainSupervisorId)),
                  _InfoRow(label: 'Co-Supervisor', value: staffName(record.coSupervisorId)),
                  _InfoRow(label: 'Examiner', value: staffName(record.examinerId)),
                ],
              ),
              _Section(
                title: 'Assignments',
                children: [
                  assignments.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(DesignSystem.spaceSm),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (e, _) => Text('Error loading assignments', style: DesignSystem.bodySm),
                    data: (items) => items.isEmpty
                        ? Text('No active assignments yet.', style: DesignSystem.bodySm)
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
                                  subtitle: Text(
                                    'Assigned: ${formatFypDate(a.assignedAt)}',
                                    style: DesignSystem.bodySm,
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
              _InfoRow(label: 'Created', value: formatFypDateTime(record.createdAt)),
              _InfoRow(label: 'Last Updated', value: formatFypDateTime(record.updatedAt)),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      color: DesignSystem.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: DesignSystem.bodySm)),
        ],
      ),
    );
  }
}