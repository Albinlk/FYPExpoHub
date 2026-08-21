import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CoordinatorDashboardPage extends ConsumerWidget {
  const CoordinatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(fypRecordsProvider);
    final expo = ref.watch(fypExpoPublicationsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Coordinator Dashboard',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (recordList) => ListView(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Records',
                    value: recordList.length.toString(),
                    icon: Icons.folder_open,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceMd),
                Expanded(
                  child: expo.when(
                    loading: () => const _StatCard(label: 'Expo Publications', value: '—', icon: Icons.public),
                    error: (e, _) => const _StatCard(label: 'Expo Publications', value: '—', icon: Icons.public),
                    data: (expoList) => _StatCard(
                      label: 'Expo Publications',
                      value: expoList.length.toString(),
                      icon: Icons.public,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceLg),
            Text('Recent Records', style: DesignSystem.h2),
            const SizedBox(height: DesignSystem.spaceMd),
            for (final record in recordList.take(20))
              Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                color: DesignSystem.surfaceContainerLowest,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.folder_open, color: DesignSystem.primary),
                  title: Text(
                    record.projectTitle?.isNotEmpty == true ? record.projectTitle! : 'Untitled Project',
                    style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${record.currentCourseCode} | ${record.workflowStatus.replaceAll('_', ' ')}',
                    style: DesignSystem.bodySm,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      color: DesignSystem.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: DesignSystem.primary, size: 32),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(value, style: DesignSystem.h2),
            Text(label, style: DesignSystem.bodySm),
          ],
        ),
      ),
    );
  }
}