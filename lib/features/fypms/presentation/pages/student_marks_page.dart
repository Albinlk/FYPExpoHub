import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentMarksPage extends ConsumerWidget {
  const StudentMarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Marks',
      builder: (context, ref, record) {
        final summaries = ref.watch(fypMarksSummariesProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Marks Summary', style: DesignSystem.h2),
              ),
            ),
            Expanded(
              child: summaries.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No marks have been finalized yet.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final s in list)
                        Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                          color: DesignSystem.surfaceContainerLowest,
                          child: Padding(
                            padding: const EdgeInsets.all(DesignSystem.spaceMd),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      s.courseCode,
                                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    if (s.grade != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceSm, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: DesignSystem.secondary.withOpacity(0.15),
                                          borderRadius: DesignSystem.radiusLg,
                                        ),
                                        child: Text(
                                          'Grade: ${s.grade}',
                                          style: DesignSystem.bodySm.copyWith(
                                            color: DesignSystem.onSecondaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: DesignSystem.spaceSm),
                                Text(
                                  'Weighted Total: ${s.weightedTotal.toStringAsFixed(2)} / 100',
                                  style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: DesignSystem.spaceXs),
                                Text(
                                  s.isFinalized ? 'Finalized' : 'Not finalized',
                                  style: DesignSystem.bodySm.copyWith(
                                    color: s.isFinalized
                                        ? DesignSystem.secondary
                                        : DesignSystem.onSurfaceVariant,
                                  ),
                                ),
                                if (s.marks.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: DesignSystem.spaceSm),
                                    child: Wrap(
                                      spacing: DesignSystem.spaceSm,
                                      runSpacing: DesignSystem.spaceXs,
                                      children: [
                                        for (final e in s.marks.entries)
                                          Chip(
                                            label: Text(
                                              '${e.key}: ${e.value}',
                                              style: DesignSystem.bodySm,
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            backgroundColor: DesignSystem.surfaceContainerLow,
                                            side: BorderSide.none,
                                          ),
                                      ],
                                    ),
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
}
