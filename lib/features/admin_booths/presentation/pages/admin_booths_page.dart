import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/booth.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';

class AdminBoothsPage extends ConsumerWidget {
  const AdminBoothsPage({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [Booth? item]) {
    final numberController = TextEditingController(text: item?.boothNumber ?? '');
    final zoneController = TextEditingController(text: item?.zone ?? 'Zone A');
    final noteController = TextEditingController(text: item?.locationNote ?? '');
    
    String? selectedProjectId = item?.projectId;
    final projects = ref.read(projectsProvider);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                item == null ? 'Register New Booth' : 'Update Booth Mapping', 
                style: DesignSystem.h3.copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: numberController,
                        decoration: const InputDecoration(labelText: 'Booth Number (e.g., A-01, B-12)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: zoneController,
                        decoration: const InputDecoration(labelText: 'Zone (e.g., Zone A, Zone B, Sector C)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(labelText: 'Location Note (Short physical description)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Allocated Project:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String?>(
                            value: selectedProjectId,
                            hint: const Text('No Project Allocated / Vacant'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No Project Allocated / Vacant'),
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
                    if (numberController.text.trim().isEmpty) return;

                    final newItem = Booth(
                      id: item?.id ?? 'booth-${DateTime.now().millisecondsSinceEpoch}',
                      eventId: 'fskm-fyp-2026',
                      boothNumber: numberController.text,
                      zone: zoneController.text,
                      locationNote: noteController.text,
                      projectId: selectedProjectId,
                      publicationStatus: 'published',
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      publishedAt: DateTime.now(),
                    );

                    if (item == null) {
                      ref.read(boothsProvider.notifier).addBooth(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booth registered successfully!')),
                      );
                    } else {
                      ref.read(boothsProvider.notifier).updateBooth(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booth mapping updated successfully!')),
                      );
                    }

                    // Automatically sync back to project's booth assignment
                    if (selectedProjectId != null) {
                      final proj = projects.firstWhere((p) => p.id == selectedProjectId);
                      ref.read(projectsProvider.notifier).updateProject(
                        proj.copyWith(
                          boothId: newItem.id,
                          boothNumber: newItem.boothNumber,
                          boothZone: newItem.zone,
                        ),
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
    final booths = ref.watch(boothsProvider);
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
                    Text('Booth Management', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 4),
                    Text('Manage booth numbers, zones, and student project allocations.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Register Booth'),
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
                    Text('Booth & Project Mapping List', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    if (booths.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('No booth mapping records found.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: booths.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = booths[index];
                          final associatedProj = projects.cast<Project?>().firstWhere(
                            (p) => p?.id == item.projectId,
                            orElse: () => null,
                          );
                          final projectTitleText = associatedProj?.title ?? 'UNASSIGNED (VACANT)';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Booth ${item.boothNumber}', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Zone: ${item.zone} • Note: ${item.locationNote}',
                                        style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.folder, size: 14, color: DesignSystem.secondary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              projectTitleText,
                                              style: DesignSystem.bodySm.copyWith(
                                                color: associatedProj == null ? DesignSystem.error : DesignSystem.secondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: associatedProj != null ? DesignSystem.secondaryContainer : DesignSystem.surfaceContainer,
                                        borderRadius: DesignSystem.radiusSm,
                                      ),
                                      child: Text(
                                        associatedProj != null ? 'Active' : 'Vacant',
                                        style: DesignSystem.labelCaps.copyWith(
                                          color: associatedProj != null ? DesignSystem.onSecondaryContainer : DesignSystem.onSurfaceVariant,
                                          fontSize: 10,
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
                                        ref.read(boothsProvider.notifier).deleteBooth(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Booth mapping deleted successfully!')),
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
