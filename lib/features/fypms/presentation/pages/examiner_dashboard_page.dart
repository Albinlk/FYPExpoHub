import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import '../../../../core/widgets/async_state.dart';
import '../../../../core/utils/fypms_format.dart';

class ExaminerDashboardPage extends ConsumerWidget {
  const ExaminerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigned = ref.watch(assignedFypRecordsProvider('examiner'));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.surfaceContainerLowest,
        foregroundColor: DesignSystem.primary,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: DesignSystem.outlineVariant)),
        title: Text(
          'Examiner Dashboard',
          style: DesignSystem.h3.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.bold),
        ),
      ),
      body: assigned.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(assignedFypRecordsProvider('examiner')), what: 'this page'),
        data: (records) => ListView(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          children: [
            Text('Records To Examine (${records.length})', style: DesignSystem.h2),
            const SizedBox(height: DesignSystem.spaceMd),
            if (records.isEmpty)
              const Center(child: Text('No records assigned to you for examination yet.'))
            else
              for (final record in records)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                    leading: const Icon(Icons.rate_review, size: 40, color: DesignSystem.primary),
                    title: Text(
                      record.projectTitle?.isNotEmpty == true ? record.projectTitle! : 'Untitled Project',
                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Course: ${record.currentCourseCode} | ${workflowStatusLabel(record.workflowStatus)}',
                      style: DesignSystem.bodySm,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/fypms/examiner/records/${record.id}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}