import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentReportsPage extends ConsumerWidget {
  const StudentReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Reports & Deliverables',
      builder: (context, ref, record) {
        final reports = ref.watch(fypReportSubmissionsProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Report Versions', style: DesignSystem.h2),
                  FilledButton.icon(
                    onPressed: () => _showSubmitReportDialog(context, ref, record),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Submit Report'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: reports.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No report submissions yet.\nUpload your proposal or final report.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final report in items)
                        Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                            leading: const Icon(Icons.article, size: 40, color: DesignSystem.primary),
                            title: Text(
                              '${report.reportType.toUpperCase()} Report v${report.version}',
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${report.status.replaceAll('_', ' ')}', style: DesignSystem.bodySm),
                                if (report.similarityIndex != null)
                                  Text('Similarity: ${report.similarityIndex}%', style: DesignSystem.bodySm),
                                if (report.reviewComment?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                    child: Text(
                                      'Review: ${report.reviewComment}',
                                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.secondary),
                                    ),
                                  ),
                                const SizedBox(height: DesignSystem.spaceSm),
                                Text(
                                  'Submitted ${report.submittedAt.toLocal()}'.replaceFirst(' 00:00:00', ''),
                                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitReportDialog(
      BuildContext context, WidgetRef ref, FypRecord record) {
    String reportType = 'proposal';
    PlatformFile? pickedFile;
    var isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(
                'Submit Report Version',
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)
                    .copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: reportType,
                        decoration: const InputDecoration(labelText: 'Report Type'),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'proposal', child: Text('Proposal (F6a)')),
                          DropdownMenuItem(value: 'final', child: Text('Final Report (F6b)')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => reportType = v);
                          }
                        },
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      OutlinedButton.icon(
                        onPressed: isUploading
                            ? null
                            : () async {
                                final result = await FilePicker.pickFiles(
                                  type: FileType.any,
                                  withData: true,
                                );
                                if (result == null || result.files.isEmpty) return;
                                setState(() {
                                  pickedFile = result.files.first;
                                });
                              },
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          pickedFile?.name ?? 'Choose File (PDF / DOCX)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUploading)
                        const Padding(
                          padding: EdgeInsets.only(top: DesignSystem.spaceMd),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (pickedFile == null) return;
                          setState(() => isUploading = true);
                          try {
                            final file = pickedFile!;
                            final bytes = file.bytes;
                            if (bytes == null) {
                              throw Exception('Could not read file bytes.');
                            }

                            final rpc = ref.read(supabaseRpcServiceProvider);
                            final storage = ref.read(supabaseStorageServiceProvider);

                            final semesters =
                                await ref.read(fypmsSemestersProvider.future);
                            final semesterCode = semesters
                                .where((s) => s.id == record.academicSemesterId)
                                .map((s) => s.code)
                                .firstOrNull ??
                                'unknown';

                            final existing = await ref
                                .read(fypReportSubmissionsProvider(record.id).future);
                            final version = existing
                                    .where((r) => r.reportType == reportType)
                                    .length +
                                1;

                            final bucket = reportType == 'final'
                                ? 'fyp-final-reports'
                                : 'fyp-proposal-reports';
                            final path = await storage.uploadFile(
                              bucket: bucket,
                              semesterCode: semesterCode,
                              fypRecordId: record.id,
                              resourceType: reportType,
                              version: version,
                              fileName: file.name,
                              bytes: bytes,
                            );

                            await rpc.submitReportVersion(
                              fypRecordId: record.id,
                              reportType: reportType,
                              fileUrl: path,
                            );

                            if (context.mounted) {
                              ref.invalidate(fypReportSubmissionsProvider(record.id));
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Report submitted successfully.')),
                              );
                            }
                          } catch (e) {
                            setState(() => isUploading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to submit: $e')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isUploading ? 'Uploading...' : 'Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
