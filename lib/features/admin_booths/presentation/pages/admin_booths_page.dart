import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/booth.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_database_service.dart' show kEventSlug;
import '../../../../core/widgets/admin_actions.dart';

class AdminBoothsPage extends ConsumerWidget {
  const AdminBoothsPage({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [Booth? item]) {
    final numberController = TextEditingController(text: item?.boothNumber ?? '');
    final zoneController = TextEditingController(text: item?.zone ?? 'Zone A');
    final noteController = TextEditingController(text: item?.locationNote ?? '');
    
    String? selectedProjectId = item?.projectId;
    final projects = ref.read(projectsProvider);
    bool saving = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(
                item == null ? 'Register New Booth' : 'Update Booth Mapping', 
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg).copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text('Allocated Project:', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: DesignSystem.spaceSm),
                      DropdownButtonFormField<String?>(
                        initialValue: selectedProjectId,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
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
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (numberController.text.trim().isEmpty) return;

                    final newItem = Booth(
                      id: item?.id ?? const Uuid().v4(),
                      eventId: item?.eventId ?? kEventSlug,
                      boothNumber: numberController.text.trim(),
                      zone: zoneController.text,
                      locationNote: noteController.text,
                      projectId: selectedProjectId,
                      publicationStatus: 'published',
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      publishedAt: DateTime.now(),
                    );

                    final booths = ref.read(boothsProvider.notifier);
                    final projectsNotifier = ref.read(projectsProvider.notifier);
                    final linked = projects.where((p) => p.id == selectedProjectId).firstOrNull;
                    setState(() => saving = true);
                    final ok = await runAdminWrite(
                      context,
                      () async {
                        // The booth row must exist before a project can point
                        // at it (projects.booth_id is a foreign key).
                        await (item == null ? booths.addBooth(newItem) : booths.updateBooth(newItem));
                        if (linked != null) {
                          await projectsNotifier.updateProject(
                            linked.copyWith(
                              boothId: newItem.id,
                              boothNumber: newItem.boothNumber,
                              boothZone: newItem.zone,
                            ),
                          );
                        }
                      },
                      success: item == null ? 'Booth registered.' : 'Booth mapping updated.',
                    );
                    if (ok && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    } else if (context.mounted) {
                      setState(() => saving = false);
                    }
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

  Widget _buildPageTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
        const SizedBox(height: 4),
        Text(subtitle, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final booths = ref.watch(boothsProvider);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPageTitle('Booth Management', 'Manage booth numbers, zones, and student project allocations.'),
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
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageTitle('Booth Management', 'Manage booth numbers, zones, and student project allocations.'),
                      const SizedBox(height: DesignSystem.spaceMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Register Booth'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.secondary,
                            foregroundColor: Colors.white,
                          ),
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
                    Text('Booth & Project Mapping List', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
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
                                      tooltip: 'Edit booth',
                                      onPressed: () => _showAddEditDialog(context, ref, item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: DesignSystem.error),
                                      tooltip: 'Delete booth',
                                      onPressed: () async {
                                        if (!await confirmDelete(context, 'booth ${item.boothNumber}')) return;
                                        if (!context.mounted) return;
                                        await runAdminWrite(
                                          context,
                                          () => ref.read(boothsProvider.notifier).deleteBooth(item.id),
                                          success: 'Booth deleted.',
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
