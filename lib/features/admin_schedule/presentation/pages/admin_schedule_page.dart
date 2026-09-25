import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/schedule_item.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_database_service.dart' show kEventSlug;
import '../../../../core/utils/schedule_format.dart';
import '../../../../core/widgets/admin_actions.dart';

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
    bool saving = false;

    // The event's configured days (plus this slot's own day, if it's
    // outside them) instead of a hardcoded 6/7 August.
    final event = ref.read(eventProvider);
    final days = scheduleDays(
      event.startAt,
      event.endAt,
      item == null ? const <ScheduleItem>[] : [item],
    );
    DateTime selectedDate = item != null ? dateOnly(item.date) : days.first;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(item == null ? 'Add Tentative Slot' : 'Update Tentative Slot', style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg).copyWith(color: DesignSystem.primary)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Slot Title (e.g. Jury Briefing)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      isDesktop
                          ? Row(
                              children: [
                                Expanded(child: TextField(controller: startAtController,                         decoration: const InputDecoration(labelText: 'Start (e.g. 09:00 AM)'))),
                                const SizedBox(width: DesignSystem.spaceMd),
                                Expanded(child: TextField(controller: endAtController, decoration: const InputDecoration(labelText: 'End (e.g. 10:00 AM)'))),
                              ],
                            )
                          : Column(
                              children: [
                                TextField(controller: startAtController,                         decoration: const InputDecoration(labelText: 'Start (e.g. 09:00 AM)')),
                                const SizedBox(height: DesignSystem.spaceSm),
                                TextField(controller: endAtController, decoration: const InputDecoration(labelText: 'End (e.g. 10:00 AM)')),
                              ],
                            ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: venueController,
                        decoration: const InputDecoration(labelText: 'Venue (e.g. Blok Kuliah, FSKM)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: audienceController,
                        decoration: const InputDecoration(labelText: 'Target Audience (e.g. Students, Jury)'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Brief Description'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      _dialogDropdown(isDesktop, 'Event Date:', DropdownButton<DateTime>(
                        value: selectedDate,
                        isExpanded: true,
                        items: [
                          for (var i = 0; i < days.length; i++)
                            DropdownMenuItem(
                              value: days[i],
                              child: Text('${longDate(days[i])} (Day ${i + 1})'),
                            ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedDate = val;
                            });
                          }
                        },
                      )),
                      const SizedBox(height: DesignSystem.spaceSm),
                      _dialogDropdown(isDesktop, 'Access:', DropdownButton<String>(
                        value: visibility,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'public', child: Text('Public')),
                          DropdownMenuItem(value: 'internal', child: Text('Internal (Committee/Jury)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              visibility = val;
                            });
                          }
                        },
                      )),
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
                  onPressed: saving ? null : () async {
                    if (titleController.text.trim().isEmpty) return;

                    final newItem = ScheduleItem(
                      id: item?.id ?? const Uuid().v4(),
                      eventId: item?.eventId ?? kEventSlug,
                      date: selectedDate,
                      startAt: startAtController.text.trim(),
                      endAt: endAtController.text.trim(),
                      title: titleController.text.trim(),
                      venue: venueController.text,
                      audience: audienceController.text,
                      description: descriptionController.text,
                      visibility: visibility,
                      publicationStatus: status,
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      publishedAt: status == 'published' ? DateTime.now() : null,
                    );

                    final notifier = ref.read(scheduleProvider.notifier);
                    setState(() => saving = true);
                    final ok = await runAdminWrite(
                      context,
                      () => item == null
                          ? notifier.addScheduleItem(newItem)
                          : notifier.updateScheduleItem(newItem),
                      success: item == null ? 'Slot added.' : 'Slot updated.',
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

  Widget _dialogDropdown(bool isDesktop, String label, Widget dropdown) {
    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(width: 250, child: dropdown),
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
    final scheduleItems = [...ref.watch(scheduleProvider)]..sort(compareScheduleItems);
    final event = ref.watch(eventProvider);
    final days = scheduleDays(event.startAt, event.endAt, scheduleItems);

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
                      _buildPageTitle('Schedule Management', 'Add, edit, or delete the exhibition event schedule below.'),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Slot'),
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
                      _buildPageTitle('Schedule Management', 'Add, edit, or delete the exhibition event schedule below.'),
                      const SizedBox(height: DesignSystem.spaceMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Slot'),
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
                    Text('Existing Slot List', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    if (scheduleItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('No schedule slots found. Please add a new slot.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
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
                          final dayIndex = days.indexWhere((d) => isSameDay(d, item.date));
                          final dayText = dayLabel(dayIndex, days[dayIndex]);

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
                                          Flexible(
                                            child: Text(item.title, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ),
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
                                         'Time: ${item.startAt} - ${item.endAt} • Venue: ${item.venue} • Access: ${item.visibility.toUpperCase()}',
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
                                      onTap: () => runAdminWrite(
                                        context,
                                        () => ref.read(scheduleProvider.notifier).togglePublish(item.id),
                                        success: isPublished ? 'Slot moved to draft.' : 'Slot published.',
                                      ),
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
                                      tooltip: 'Edit schedule item',
                                      onPressed: () => _showAddEditDialog(context, ref, item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: DesignSystem.error),
                                      tooltip: 'Delete schedule item',
                                      onPressed: () async {
                                        if (!await confirmDelete(context, '"${item.title}"')) return;
                                        if (!context.mounted) return;
                                        await runAdminWrite(
                                          context,
                                          () => ref.read(scheduleProvider.notifier).deleteScheduleItem(item.id),
                                          success: 'Slot deleted.',
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
