import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/academic_semester.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CspOfferingsPage extends ConsumerWidget {
  const CspOfferingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(fypmsOfferingsProvider);
    final semesters = ref.watch(fypmsSemestersProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Course Offerings',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: offerings.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No active course offerings found.'));
          }
          final semesterCodeById = <String, String>{
            for (final s in semesters.asData?.value ?? const <AcademicSemester>[])
              s.id: s.code,
          };
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final offering in list)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                    leading: const Icon(Icons.school, size: 40, color: DesignSystem.primary),
                    title: Text(
                      '${offering.courseCode} — ${semesterCodeById[offering.academicSemesterId] ?? offering.academicSemesterId}',
                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Enrollment: ${offering.maxStudents} | ${offering.isActive ? 'Active' : 'Inactive'}',
                      style: DesignSystem.bodySm,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/fypms/csp/milestones'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
