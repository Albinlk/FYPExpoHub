import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CspDashboardPage extends ConsumerWidget {
  const CspDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(fypmsOfferingsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'CSP Lecturer Dashboard',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: offerings.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (offerings) => ListView(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          children: [
            Text('My Course Offerings (${offerings.length})', style: DesignSystem.h2),
            const SizedBox(height: DesignSystem.spaceMd),
            if (offerings.isEmpty)
              const Center(child: Text('No active course offerings found.'))
            else
              for (final offering in offerings)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                    leading: const Icon(Icons.school, size: 40, color: DesignSystem.primary),
                    title: Text(
                      '${offering.courseCode} — ${offering.academicSemesterId}',
                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Enrollment: ${offering.maxStudents} | ${offering.isActive ? 'Active' : 'Inactive'}',
                      style: DesignSystem.bodySm,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/fypms/csp/offerings/${offering.id}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}