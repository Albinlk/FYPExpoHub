import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';

class CoordinatorRecordsPage extends ConsumerWidget {
  const CoordinatorRecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(fypRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'All FYP Records',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DesignSystem.spaceMd),
            child: FilledButton.icon(
              onPressed: () => _showCreateRecordDialog(context, ref),
              style: FilledButton.styleFrom(
                backgroundColor: DesignSystem.secondary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('New Record'),
            ),
          ),
        ],
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_open, size: 48, color: DesignSystem.primary),
                  const SizedBox(height: DesignSystem.spaceMd),
                  Text('No FYP records yet.', style: DesignSystem.bodyMd),
                  const SizedBox(height: DesignSystem.spaceMd),
                  FilledButton.icon(
                    onPressed: () => _showCreateRecordDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Record'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final record in list)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                    leading: const Icon(Icons.folder_open, size: 40, color: DesignSystem.primary),
                    title: Text(
                      record.projectTitle?.isNotEmpty == true
                          ? record.projectTitle!
                          : 'Untitled Project',
                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${record.currentCourseCode} | ${record.workflowStatus.replaceAll('_', ' ')}',
                      style: DesignSystem.bodySm,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/fypms/coordinator/records/${record.id}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateRecordDialog(BuildContext context, WidgetRef ref) {
    String? semesterId;
    String? studentId;
    String? courseCode;
    String programmeCode = '';
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final matricIdController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('Create FYP Record', style: DesignSystem.h2),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final semesters = ref.watch(fypmsSemestersProvider);
                        return semesters.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                          data: (items) => DropdownButtonFormField<String>(
                            initialValue: semesterId,
                            decoration: const InputDecoration(labelText: 'Academic Semester'),
                            items: [
                              for (final s in items)
                                DropdownMenuItem(
                                  value: s.id,
                                  child: Text('${s.code} — ${s.label}'),
                                ),
                            ],
                            onChanged: (v) => setState(() => semesterId = v),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    Consumer(
                      builder: (context, ref, _) {
                        final students = ref.watch(fypStudentsProvider);
                        return students.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                          data: (items) => DropdownButtonFormField<String>(
                            initialValue: studentId,
                            decoration: const InputDecoration(labelText: 'Student'),
                            items: [
                              for (final s in items)
                                DropdownMenuItem(
                                  value: s['id'] as String?,
                                  child: Text(
                                    '${s['display_name']} (${s['programme_code']})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (v) => setState(() {
                              studentId = v;
                              final student = items.where((s) => s['id'] == v).firstOrNull;
                              programmeCode = (student?['programme_code'] as String?) ?? '';
                            }),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    Consumer(
                      builder: (context, ref, _) {
                        final courses = ref.watch(fypmsCoursesProvider);
                        return courses.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                          data: (items) {
                            final csp = items
                                .where((c) => c.code == 'CSP600' || c.code == 'CSP650')
                                .toList();
                            return DropdownButtonFormField<String>(
                              initialValue: courseCode,
                              decoration: const InputDecoration(labelText: 'Course'),
                              items: [
                                for (final c in csp)
                                  DropdownMenuItem(
                                    value: c.code,
                                    child: Text('${c.code} — ${c.name}'),
                                  ),
                              ],
                              onChanged: (v) => setState(() => courseCode = v),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Project Title (optional)'),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Project Description (optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: matricIdController,
                      decoration: const InputDecoration(labelText: 'Matric ID (optional)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: semesterId == null || studentId == null || courseCode == null
                      ? null
                      : () async {
                          try {
                            final rpc = ref.read(supabaseRpcServiceProvider);
                            await rpc.createFypRecord(
                              academicSemesterId: semesterId!,
                              studentId: studentId!,
                              currentCourseCode: courseCode!,
                              programmeCode: programmeCode,
                              matricId: matricIdController.text.trim().isEmpty
                                  ? null
                                  : matricIdController.text.trim(),
                              projectTitle: titleController.text.trim().isEmpty
                                  ? null
                                  : titleController.text.trim(),
                              projectDescription:
                                  descriptionController.text.trim().isEmpty
                                      ? null
                                      : descriptionController.text.trim(),
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            ref.invalidate(fypRecordsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('FYP record created.')),
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          }
                        },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
