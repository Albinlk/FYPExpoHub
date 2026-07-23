import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/state_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final projects = ref.watch(projectsProvider);
    final booths = ref.watch(boothsProvider);
    final schedule = ref.watch(scheduleProvider);
    final imports = ref.watch(importsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview Dashboard', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Welcome to the FYP Expo Hub administration panel.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXl),

            // Statistics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: DesignSystem.spaceMd,
              mainAxisSpacing: DesignSystem.spaceMd,
              childAspectRatio: isDesktop ? 1.5 : 1.2,
              children: [
                _buildStatCard('Total Projects', '${projects.length}', Icons.folder, Colors.blue),
                _buildStatCard('Booths Available', '${booths.length}', Icons.map, Colors.green),
                _buildStatCard('Event Schedules', '${schedule.length}', Icons.schedule, Colors.orange),
                _buildStatCard('Files Imported', '${imports.length}', Icons.file_upload, Colors.purple),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXl),

            // Quick Actions & Recent Imports Columns
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildRecentImports(context, ref)),
                      const SizedBox(width: DesignSystem.spaceLg),
                      Expanded(flex: 2, child: _buildQuickActions(context)),
                    ],
                  )
                : Column(
                    children: [
                      _buildQuickActions(context),
                      const SizedBox(height: DesignSystem.spaceLg),
                      _buildRecentImports(context, ref),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(value, style: DesignSystem.h1.copyWith(color: DesignSystem.primary, fontSize: 28)),
              ],
            ),
            Icon(icon, size: 36, color: color.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceLg),
            _buildActionButton(context, 'Import New Master File', Icons.file_upload, '/admin/imports'),
            const SizedBox(height: DesignSystem.spaceSm),
            _buildActionButton(context, 'Update Event Details', Icons.info_outline, '/admin/event'),
            const SizedBox(height: DesignSystem.spaceSm),
            _buildActionButton(context, 'Manage Event Schedules', Icons.schedule, '/admin/schedule'),
            const SizedBox(height: DesignSystem.spaceSm),
            _buildActionButton(context, 'Review Student Projects', Icons.folder_open, '/admin/projects'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, String route) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.go(route),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignSystem.primary,
          side: const BorderSide(color: DesignSystem.surfaceContainer),
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildRecentImports(BuildContext context, WidgetRef ref) {
    final imports = ref.watch(importsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Import History', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceLg),
            imports.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(DesignSystem.spaceMd),
                    child: Text('No import history found.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: imports.length,
                    itemBuilder: (context, index) {
                      final imp = imports[index];
                      final isPending = imp.status == 'pending_review';
                      final statusText = isPending ? 'Pending Review' : 'Published';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(imp.sourceFileName, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                                const SizedBox(height: 2),
                                Text('ID: ${imp.id} • Date: ${imp.uploadedAt.day}/${imp.uploadedAt.month}/${imp.uploadedAt.year}', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPending ? DesignSystem.secondaryContainer : DesignSystem.surfaceContainer,
                                    borderRadius: DesignSystem.radiusSm,
                                  ),
                                  child: Text(
                                    statusText,
                                    style: DesignSystem.labelCaps.copyWith(
                                      color: isPending ? DesignSystem.onSecondaryContainer : DesignSystem.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onPressed: () => context.go('/admin/imports/${imp.id}'),
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
    );
  }
}
