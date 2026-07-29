import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/announcement.dart';
import '../../../../core/state/state_providers.dart';

class AdminAnnouncementsPage extends ConsumerWidget {
  const AdminAnnouncementsPage({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [Announcement? item]) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final bodyController = TextEditingController(text: item?.body ?? '');
    final categoryController = TextEditingController(text: item?.category ?? 'Important');
    
    bool pinned = item?.pinned ?? false;
    String status = item?.publicationStatus ?? 'published';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(
                item == null ? 'Create New Announcement' : 'Update Announcement', 
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg).copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Announcement Title'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(labelText: 'Category (e.g., Important, Logistical, General)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: bodyController,
                        decoration: const InputDecoration(labelText: 'Announcement Body (Description)'),
                        maxLines: 4,
                      ),
                      const SizedBox(height: DesignSystem.spaceLg),
                      CheckboxListTile(
                        title: const Text('Pin Announcement (Display at the top)'),
                        value: pinned,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              pinned = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      _dialogDropdown(isDesktop, 'Publication Status:', DropdownButton<String>(
                        value: status,
                        isExpanded: true,
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
                      )),
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

                    final newItem = Announcement(
                      id: item?.id ?? 'ann-${DateTime.now().millisecondsSinceEpoch}',
                      eventId: 'fskm-fyp-2026',
                      title: titleController.text,
                      body: bodyController.text,
                      category: categoryController.text,
                      pinned: pinned,
                      publicationStatus: status,
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      publishedAt: status == 'published' ? DateTime.now() : (item?.publishedAt ?? DateTime.now()),
                    );

                    if (item == null) {
                      ref.read(announcementsProvider.notifier).addAnnouncement(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Announcement created successfully!')),
                      );
                    } else {
                      ref.read(announcementsProvider.notifier).updateAnnouncement(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Announcement updated successfully!')),
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

  Widget _dialogDropdown(bool isDesktop, String label, Widget dropdown) {
    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(width: 200, child: dropdown),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: DesignSystem.spaceSm),
        dropdown,
      ],
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
    final announcements = ref.watch(announcementsProvider);

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
                      _buildPageTitle('Announcements Management', 'Create, modify, or publish announcements for the public portal.'),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Announcement'),
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
                      _buildPageTitle('Announcements Management', 'Create, modify, or publish announcements for the public portal.'),
                      const SizedBox(height: DesignSystem.spaceMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Announcement'),
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
                    Text('All Announcements', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    if (announcements.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('No announcements found.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: announcements.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = announcements[index];
                          final isPublished = item.publicationStatus == 'published';

                          // Format Date helper
                          final dateText = "${item.createdAt.day} ${item.createdAt.month == 7 ? "July" : "August"} ${item.createdAt.year}";

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
                                          if (item.pinned)
                                            const Padding(
                                              padding: EdgeInsets.only(right: 6.0),
                                              child: Icon(Icons.push_pin, color: DesignSystem.secondary, size: 14),
                                            ),
                                          Text(item.title, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text('Date: $dateText • Category: ${item.category}', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                                      if (item.body.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            item.body,
                                            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => ref.read(announcementsProvider.notifier).togglePublish(item.id),
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
                                        ref.read(announcementsProvider.notifier).deleteAnnouncement(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Announcement deleted successfully!')),
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
