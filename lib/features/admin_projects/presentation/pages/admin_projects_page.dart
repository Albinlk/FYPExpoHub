import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';

class AdminProjectsPage extends ConsumerWidget {
  const AdminProjectsPage({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [Project? item]) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final matricIdController = TextEditingController(text: item?.matricId ?? '');
    final codeController = TextEditingController(text: item?.programmeCode ?? 'CS230');
    final progNameController = TextEditingController(text: item?.programmeName ?? 'CS230 (Computer Science)');
    final descController = TextEditingController(text: item?.shortDescription ?? '');
    final categoryController = TextEditingController(text: item?.category ?? 'AI & Machine Learning');
    final tagsController = TextEditingController(text: item?.technologyTags.join(', ') ?? 'Flutter, Dart, Firebase');
    final studentsController = TextEditingController(text: item?.teamDisplayNames.join(', ') ?? '');
    final supervisorController = TextEditingController(text: item?.supervisorDisplayName ?? '');
    final examinerController = TextEditingController(text: item?.examinerDisplayName ?? '');
    final boothNumController = TextEditingController(text: item?.boothNumber ?? '');
    final boothZoneController = TextEditingController(text: item?.boothZone ?? 'Zone A');
    final demoController = TextEditingController(text: item?.demoUrl ?? '');
    final coverController = TextEditingController(text: item?.coverImageUrl ?? 'assets/images/project_placeholder.jpg');

    String status = item?.publicationStatus ?? 'published';
    bool featured = item?.featured ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                item == null ? 'Add New Project' : 'Update Project', 
                style: DesignSystem.h3.copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 600,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Project Title'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: matricIdController,
                              decoration: const InputDecoration(labelText: 'Matric ID'),
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(
                            child: TextField(
                              controller: codeController,
                              decoration: const InputDecoration(labelText: 'Program Code (e.g., CS240)'),
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(
                            child: TextField(
                              controller: progNameController,
                              decoration: const InputDecoration(labelText: 'Program Name'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Short Description'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: categoryController,
                              decoration: const InputDecoration(labelText: 'Project Category'),
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(
                            child: TextField(
                              controller: tagsController,
                              decoration: const InputDecoration(labelText: 'Technology Tags (separated by comma)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: studentsController,
                              decoration: const InputDecoration(labelText: 'Student Name(s) / Team (separated by comma)'),
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(
                            child: TextField(
                              controller: supervisorController,
                              decoration: const InputDecoration(labelText: 'Supervisor Name'),
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(
                            child: TextField(
                              controller: examinerController,
                              decoration: const InputDecoration(labelText: 'Examiner Name'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: boothNumController,
                              decoration: const InputDecoration(labelText: 'Booth Number (e.g., A-01)'),
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(
                            child: TextField(
                              controller: boothZoneController,
                              decoration: const InputDecoration(labelText: 'Booth Zone (e.g., Zone A)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: demoController,
                        decoration: const InputDecoration(labelText: 'Demo URL'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: coverController,
                        decoration: const InputDecoration(labelText: 'Cover Image URL'),
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      CheckboxListTile(
                        title: const Text('Highlight as Featured Project'),
                        value: featured,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              featured = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Publication Status:', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: status,
                            items: const [
                              DropdownMenuItem(value: 'published', child: Text('Published')),
                              DropdownMenuItem(value: 'draft', child: Text('Draft')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  status = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;

                    final newItem = Project(
                      id: item?.id ?? 'proj-${DateTime.now().millisecondsSinceEpoch}',
                      eventId: 'fskm-fyp-2026',
                      slug: titleController.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
                      title: titleController.text,
                      matricId: matricIdController.text.isEmpty ? null : matricIdController.text,
                      programmeCode: codeController.text,
                      programmeName: progNameController.text,
                      shortDescription: descController.text,
                      category: categoryController.text,
                      technologyTags: tagsController.text.split(',').map((e) => e.trim()).toList(),
                      teamDisplayNames: studentsController.text.split(',').map((e) => e.trim()).toList(),
                      supervisorDisplayName: supervisorController.text,
                      examinerDisplayName: examinerController.text.isEmpty ? null : examinerController.text,
                      boothNumber: boothNumController.text.isEmpty ? null : boothNumController.text,
                      boothZone: boothZoneController.text.isEmpty ? null : boothZoneController.text,
                      boothId: boothNumController.text.isEmpty ? null : 'booth-${boothNumController.text}',
                      demoUrl: demoController.text.isEmpty ? null : demoController.text,
                      coverImageUrl: coverController.text,
                      featured: featured,
                      publicationStatus: status,
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      publishedAt: status == 'published' ? DateTime.now() : null,
                    );

                    if (item == null) {
                      ref.read(projectsProvider.notifier).addProject(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project added successfully!')),
                      );
                    } else {
                      ref.read(projectsProvider.notifier).updateProject(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project updated successfully!')),
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project Catalog Management', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 4),
                    Text('Manage the complete list of student final year projects.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Project Catalog', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    if (projects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('No student projects found.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projects.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = projects[index];
                          final isPublished = item.publicationStatus == 'published';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(item.title, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                                          const SizedBox(width: 8),
                                          if (item.featured)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade100,
                                                borderRadius: DesignSystem.radiusSm,
                                                border: Border.all(color: Colors.amber.shade300, width: 1),
                                              ),
                                              child: Text(
                                                'FEATURED',
                                                style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold, fontSize: 8),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Program: ${item.programmeCode} • Student(s): ${item.teamDisplayNames.join(', ')} • Supervisor: ${item.supervisorDisplayName}${item.examinerDisplayName != null ? ' • Examiner: ${item.examinerDisplayName}' : ''}',
                                        style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                      ),
                                      if (item.boothNumber != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2.0),
                                          child: Text(
                                            'Booth: ${item.boothNumber} (${item.boothZone ?? "Zone A"})',
                                            style: DesignSystem.bodySm.copyWith(color: DesignSystem.secondary, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => ref.read(projectsProvider.notifier).togglePublishStatus(item.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPublished ? DesignSystem.secondaryContainer : DesignSystem.surfaceContainer,
                                          borderRadius: DesignSystem.radiusSm,
                                        ),
                                        child: Text(
                                          isPublished ? 'Published' : 'Draft',
                                          style: DesignSystem.labelCaps.copyWith(
                                            color: isPublished ? DesignSystem.onSecondaryContainer : DesignSystem.primary,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () => _showAddEditDialog(context, ref, item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: DesignSystem.error),
                                      onPressed: () {
                                        ref.read(projectsProvider.notifier).deleteProject(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Project deleted successfully!')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
