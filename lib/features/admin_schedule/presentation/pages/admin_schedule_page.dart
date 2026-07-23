import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/schedule_item.dart';
import '../../../../core/state/state_providers.dart';

class AdminSchedulePage extends ConsumerWidget {
  const AdminSchedulePage({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [ScheduleItem? item]) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final venueController = TextEditingController(text: item?.venue ?? '');
    final audienceController = TextEditingController(text: item?.audience ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final startAtController = TextEditingController(text: item?.startAt ?? '09:00 AM');
    final endAtController = TextEditingController(text: item?.endAt ?? '10:00 AM');
    
    String visibility = item?.visibility ?? 'public';
    String status = item?.publicationStatus ?? 'published';
    DateTime selectedDate = item?.date ?? DateTime(2026, 8, 6);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item == null ? 'Tambah Slot Tentatif' : 'Kemaskini Slot Tentatif', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Tajuk Slot (e.g. Taklimat Juri)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startAtController,
                              decoration: const InputDecoration(labelText: 'Mula (e.g. 09:00 AM)'),
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceMd),
                          Expanded(
                            child: TextField(
                              controller: endAtController,
                              decoration: const InputDecoration(labelText: 'Tamat (e.g. 10:00 AM)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: venueController,
                        decoration: const InputDecoration(labelText: 'Tempat (e.g. Blok Kuliah, FSKM)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: audienceController,
                        decoration: const InputDecoration(labelText: 'Sasaran Audien (e.g. Pelajar, Juri)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Keterangan/Syarahan ringkas'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tarikh Acara:', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                          DropdownButton<int>(
                            value: selectedDate.day,
                            items: const [
                              DropdownMenuItem(value: 6, child: Text('6 Ogos 2026 (Hari 1)')),
                              DropdownMenuItem(value: 7, child: Text('7 Ogos 2026 (Hari 2)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedDate = DateTime(2026, 8, val);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Akses:', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: visibility,
                            items: const [
                              DropdownMenuItem(value: 'public', child: Text('Public (Awam)')),
                              DropdownMenuItem(value: 'internal', child: Text('Internal (Urusetia/Juri)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  visibility = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status Terbitan:', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
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
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;

                    final newItem = ScheduleItem(
                      id: item?.id ?? 'sch-${DateTime.now().millisecondsSinceEpoch}',
                      eventId: 'fskm-fyp-2026',
                      date: selectedDate,
                      startAt: startAtController.text,
                      endAt: endAtController.text,
                      title: titleController.text,
                      venue: venueController.text,
                      audience: audienceController.text,
                      description: descriptionController.text,
                      visibility: visibility,
                      publicationStatus: status,
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      publishedAt: status == 'published' ? DateTime.now() : null,
                    );

                    if (item == null) {
                      ref.read(scheduleProvider.notifier).addScheduleItem(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Slot tentatif berjaya ditambah!')),
                      );
                    } else {
                      ref.read(scheduleProvider.notifier).updateScheduleItem(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Slot tentatif berjaya dikemaskini!')),
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
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
    final scheduleItems = ref.watch(scheduleProvider);

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
                    Text('Pengurusan Tentatif', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 4),
                    Text('Tambah, edit, atau padam jadual acara pameran di bawah.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Slot'),
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
                    Text('Senarai Slot Sedia Ada', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    if (scheduleItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('Tiada slot jadual ditemui. Sila tambah slot baru.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: scheduleItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = scheduleItems[index];
                          final isPublished = item.publicationStatus == 'published';
                          final dayText = item.date.day == 6 ? 'Hari 1 (6 Ogos)' : 'Hari 2 (7 Ogos)';

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
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: DesignSystem.surfaceContainer,
                                              borderRadius: DesignSystem.radiusSm,
                                            ),
                                            child: Text(
                                              dayText,
                                              style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary, fontSize: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Waktu: ${item.startAt} - ${item.endAt} • Tempat: ${item.venue} • Akses: ${item.visibility.toUpperCase()}',
                                        style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                      ),
                                      if (item.description != null && item.description!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            item.description!,
                                            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => ref.read(scheduleProvider.notifier).togglePublish(item.id),
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
                                        ref.read(scheduleProvider.notifier).deleteScheduleItem(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Slot tentatif berjaya dipadam!')),
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
