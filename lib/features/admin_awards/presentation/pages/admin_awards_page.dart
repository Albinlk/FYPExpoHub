import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/award.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';

class AdminAwardsPage extends ConsumerWidget {
  const AdminAwardsPage({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [PublishedAwardWinner? item]) {
    final titleController = TextEditingController(text: item?.projectTitle ?? 'Gold Innovation Award');
    final descController = TextEditingController(text: '');
    final sponsorController = TextEditingController(text: '');
    
    String? selectedProjectId = item?.projectId;
    String status = item?.publicationStatus ?? 'published';

    final projects = ref.read(projectsProvider);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item == null ? 'Add Award Record' : 'Update Award Record', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Category / Award Name'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: sponsorController,
                        decoration: const InputDecoration(labelText: 'Sponsor / Partner (e.g. Petronas, Maybank)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Description / Additional Notes'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Winning Project:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String?>(
                            value: selectedProjectId,
                            hint: const Text('Select Project'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Please Select a Project'),
                              ),
                              ...projects.map((p) {
                                return DropdownMenuItem<String?>(
                                  value: p.id,
                                  child: Text(p.title.length > 30 ? '${p.title.substring(0, 30)}...' : p.title),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedProjectId = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Publication Status:', style: TextStyle(fontWeight: FontWeight.bold)),
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

                    // Fetch student names from selected project
                    final associatedProj = projects.cast<Project?>().firstWhere(
                      (p) => p?.id == selectedProjectId,
                      orElse: () => null,
                    );

                    final newItem = PublishedAwardWinner(
                      id: item?.id ?? 'award-${DateTime.now().millisecondsSinceEpoch}',
                      eventId: 'fskm-fyp-2026',
                      awardCategoryId: 'cat-manual',
                      projectId: selectedProjectId ?? 'none',
                      projectTitle: titleController.text,
                      teamDisplayName: associatedProj?.teamDisplayNames.join(', ') ?? 'N/A',
                      supervisorDisplayName: associatedProj?.supervisorDisplayName ?? 'N/A',
                      programmeCode: associatedProj?.programmeCode ?? 'N/A',
                      publicationStatus: status,
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      publishedAt: status == 'published' ? DateTime.now() : null,
                    );

                    if (item == null) {
                      ref.read(awardsProvider.notifier).addWinner(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Award record created successfully!')),
                      );
                    } else {
                      ref.read(awardsProvider.notifier).updateWinner(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Award record updated successfully!')),
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
    final awards = ref.watch(awardsProvider);

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
                    Text('Award Winners Management', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 4),
                    Text('Manage special award categories and register innovation winners.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Record'),
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
                    Text('Exhibition Award & Category Listings', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    if (awards.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('No award winner records found.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: awards.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = awards[index];
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
                                      Text(item.projectTitle, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Students: ${item.teamDisplayName} • Supervisor: ${item.supervisorDisplayName}',
                                        style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        final updated = item.copyWith(
                                          publicationStatus: isPublished ? 'draft' : 'published',
                                          publishedAt: !isPublished ? DateTime.now() : null,
                                          updatedAt: DateTime.now(),
                                        );
                                        ref.read(awardsProvider.notifier).updateWinner(updated);
                                      },
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
                                        ref.read(awardsProvider.notifier).deleteWinner(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Award winner record deleted successfully!')),
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
