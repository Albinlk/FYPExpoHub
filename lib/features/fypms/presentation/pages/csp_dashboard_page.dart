import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/academic_semester.dart';
import '../../../../core/domain/models/fypms/fyp_course_offering.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CspDashboardPage extends ConsumerWidget {
  const CspDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(myFypmsOfferingsProvider);
    final semesters = ref.watch(fypmsSemestersProvider);

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
        data: (list) => ListView(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          children: [
            Text('My Course Offerings (${list.length})', style: DesignSystem.h2),
            const SizedBox(height: DesignSystem.spaceMd),
            if (list.isEmpty)
              const Center(child: Text('No active course offerings found.'))
            else
              for (final offering in list)
                _OfferingCard(
                  offering: offering,
                  semesterLabel: _semesterLabel(semesters.asData?.value, offering),
                ),
            const SizedBox(height: DesignSystem.spaceLg),
            Text('Quick Actions', style: DesignSystem.h2),
            const SizedBox(height: DesignSystem.spaceMd),
            Wrap(
              spacing: DesignSystem.spaceMd,
              runSpacing: DesignSystem.spaceSm,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.rate_review, color: DesignSystem.primary),
                  label: const Text('Supervision Requests'),
                  onPressed: () => context.go('/fypms/csp/requests'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.timeline, color: DesignSystem.primary),
                  label: const Text('Milestones'),
                  onPressed: () => context.go('/fypms/csp/milestones'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.assessment, color: DesignSystem.primary),
                  label: const Text('Marks'),
                  onPressed: () => context.go('/fypms/csp/marks'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _semesterLabel(List<AcademicSemester>? semesters, FypCourseOffering offering) {
    if (semesters == null) return offering.academicSemesterId;
    for (final s in semesters) {
      if (s.id == offering.academicSemesterId) return s.code;
    }
    return offering.academicSemesterId;
  }
}

class _OfferingCard extends ConsumerWidget {
  final FypCourseOffering offering;
  final String semesterLabel;

  const _OfferingCard({required this.offering, required this.semesterLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(fypRecordsProvider);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      color: DesignSystem.surfaceContainerLowest,
      child: ListTile(
        contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
        leading: const Icon(Icons.school, size: 40, color: DesignSystem.primary),
        title: Text(
          '${offering.courseCode} — $semesterLabel',
          style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Enrollment: ${offering.maxStudents ?? '-'} | '
          '${records.asData?.value.where((r) => r.currentCourseCode == offering.courseCode).length ?? 0} '
          'FYP records | ${offering.isActive ? 'Active' : 'Inactive'}',
          style: DesignSystem.bodySm,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/fypms/csp/milestones'),
      ),
    );
  }
}
