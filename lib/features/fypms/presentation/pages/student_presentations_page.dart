import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

/// The student's scheduled presentation slots (progress presentation,
/// defence, exhibition) with the session's venue and time.
class StudentPresentationsPage extends ConsumerWidget {
  const StudentPresentationsPage({super.key});

  static String _time(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Presentations',
      builder: (context, ref, record) {
        final slots = ref.watch(fypRecordPresentationsProvider(record.id));
        return slots.when(
          loading: () => const FypmsLoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.gutter),
                  child: Text(
                    'No presentation has been scheduled for you yet.\n'
                    'Your course lecturer will assign your slot.',
                    style: DesignSystem.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                final where = [p.room, p.venue].whereType<String>().where((s) => s.isNotEmpty).toSet().join(' · ');
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                    leading: Icon(
                      p.sessionType == 'expo' ? Icons.storefront : Icons.co_present,
                      size: 36,
                      color: DesignSystem.primary,
                    ),
                    title: Text(
                      '${p.sessionCode ?? ''} — ${p.sessionTitle ?? 'Presentation'}',
                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${formatFypDate(p.startAt.toLocal())}, ${_time(p.startAt)}–${_time(p.endAt)}'
                      ' · Slot ${p.slotNumber}${where.isEmpty ? '' : '\n$where'}',
                      style: DesignSystem.bodySm,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
