import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);
    final records = ref.watch(myFypRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Student Dashboard',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.gutter),
        child: records.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading records: $e')),
          data: (list) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${user?.email ?? 'Student'}', style: DesignSystem.h2),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  list.isEmpty
                      ? 'You do not have any FYP records yet.'
                      : 'You have ${list.length} active FYP record${list.length == 1 ? '' : 's'}.',
                  style: DesignSystem.bodyMd,
                ),
                const SizedBox(height: DesignSystem.spaceLg),
                if (list.isEmpty)
                  _EmptyState(onCreate: () => context.go('/fypms/student/records'))
                else
                  ...list.map((record) => _RecordCard(record: record)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecordCard extends ConsumerWidget {
  final FypRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = record;
    final title = r.projectTitle?.isNotEmpty == true ? r.projectTitle! : 'Untitled Project';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      color: DesignSystem.surfaceContainerLowest,
      child: ListTile(
        contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
        leading: const Icon(Icons.folder_open, size: 40, color: DesignSystem.primary),
        title: Text(title, style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DesignSystem.spaceXs),
            Text('Course: ${r.currentCourseCode}', style: DesignSystem.bodySm),
            const SizedBox(height: DesignSystem.spaceXs),
            Text('Programme: ${r.programmeCode}', style: DesignSystem.bodySm),
            const SizedBox(height: DesignSystem.spaceSm),
            FypStatusBadge.workflow(r.workflowStatus),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/fypms/student/records/${r.id}'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open, size: 64, color: DesignSystem.onSurfaceVariant),
          const SizedBox(height: DesignSystem.spaceMd),
          Text('No FYP Records', style: DesignSystem.h3),
          const SizedBox(height: DesignSystem.spaceSm),
          Text(
            'Create your first FYP record to begin the workflow.',
            style: DesignSystem.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignSystem.spaceLg),
          FilledButton(
            onPressed: onCreate,
            child: const Text('Create FYP Record'),
          ),
        ],
      ),
    );
  }
}